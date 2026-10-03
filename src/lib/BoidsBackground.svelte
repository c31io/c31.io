<script>
  import { onMount } from 'svelte';
  import shader from './boids.wgsl?raw';

  const BOID_COUNT = 160;
  const FRAME_INTERVAL = 1000 / 30;

  /** @type {HTMLCanvasElement} */
  let canvas;
  let ready = false;

  onMount(() => {
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
    const darkMode = window.matchMedia('(prefers-color-scheme: dark)');
    const parameters = new Float32Array(12);
    new Uint32Array(parameters.buffer)[3] = BOID_COUNT;

    /** @type {GPUDevice | undefined} */
    let device;
    /** @type {GPUCanvasContext | null} */
    let context = null;
    /** @type {GPUBuffer[]} */
    const buffers = [];
    /** @type {FrameRequestCallback | undefined} */
    let render;
    let disposed = false;
    let unavailable = false;
    let initializing = false;
    let frame = 0;
    let lastTime = 0;
    let nextTime = 0;

    function stop() {
      cancelAnimationFrame(frame);
      frame = 0;
      lastTime = 0;
      nextTime = 0;
      ready = false;
    }

    function release() {
      stop();
      render = undefined;
      context?.unconfigure();
      context = null;
      for (const buffer of buffers) buffer.destroy();
      buffers.length = 0;
      device?.destroy();
      device = undefined;
    }

    function resize() {
      if (!device) return;
      const width = canvas.clientWidth;
      const height = canvas.clientHeight;
      if (!width || !height) return;
      const limit = device.limits.maxTextureDimension2D;
      const scale = Math.min(window.devicePixelRatio || 1, 2, limit / width, limit / height);
      const pixelWidth = Math.max(1, Math.round(width * scale));
      const pixelHeight = Math.max(1, Math.round(height * scale));
      if (canvas.width !== pixelWidth) canvas.width = pixelWidth;
      if (canvas.height !== pixelHeight) canvas.height = pixelHeight;
      parameters[0] = width / height;
      parameters[1] = 1;
      parameters[8] = 2 / width;
      parameters[9] = 2 / height;
    }

    function updateColor() {
      const color = darkMode.matches ? 1 : 0;
      parameters[4] = color;
      parameters[5] = color;
      parameters[6] = color;
      parameters[7] = darkMode.matches ? 0.22 : 0.18;
    }

    function sync() {
      stop();
      if (disposed || unavailable || reducedMotion.matches || document.hidden) return;
      if (render) {
        resize();
        frame = requestAnimationFrame(render);
      } else if (!initializing && navigator.gpu) {
        void initialize();
      }
    }

    async function initialize() {
      initializing = true;
      try {
        const adapter = await navigator.gpu.requestAdapter({ powerPreference: 'low-power' });
        if (disposed) return;
        if (!adapter) {
          unavailable = true;
          return;
        }
        const gpu = await adapter.requestDevice();
        if (disposed) {
          gpu.destroy();
          return;
        }
        device = gpu;
        const gpuContext = canvas.getContext('webgpu');
        if (!gpuContext) {
          unavailable = true;
          release();
          return;
        }
        context = gpuContext;
        const format = navigator.gpu.getPreferredCanvasFormat();
        gpuContext.configure({ device: gpu, format, alphaMode: 'premultiplied' });
        gpu.addEventListener('uncapturederror', () => {
          unavailable = true;
          release();
        });
        void gpu.lost.then(() => {
          if (disposed || device !== gpu) return;
          unavailable = true;
          release();
        });

        const initial = new Float32Array(BOID_COUNT * 4);
        for (let i = 0; i < BOID_COUNT; i++) {
          const angle = Math.random() * Math.PI * 2;
          const speed = 0.028 + Math.random() * 0.012;
          initial[i * 4] = Math.random();
          initial[i * 4 + 1] = Math.random();
          initial[i * 4 + 2] = Math.cos(angle) * speed;
          initial[i * 4 + 3] = Math.sin(angle) * speed;
        }
        const states = [0, 1].map(() => gpu.createBuffer({
          size: initial.byteLength,
          usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
        }));
        const uniforms = gpu.createBuffer({
          size: parameters.byteLength,
          usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
        });
        buffers.push(...states, uniforms);
        gpu.queue.writeBuffer(states[0], 0, initial);

        const bindings = gpu.createBindGroupLayout({
          entries: [
            {
              binding: 0,
              visibility: GPUShaderStage.COMPUTE | GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT,
              buffer: { type: 'uniform' },
            },
            {
              binding: 1,
              visibility: GPUShaderStage.COMPUTE | GPUShaderStage.VERTEX,
              buffer: { type: 'read-only-storage' },
            },
            {
              binding: 2,
              visibility: GPUShaderStage.COMPUTE,
              buffer: { type: 'storage' },
            },
          ],
        });
        const groups = states.map((input, index) => gpu.createBindGroup({
          layout: bindings,
          entries: [
            { binding: 0, resource: { buffer: uniforms } },
            { binding: 1, resource: { buffer: input } },
            { binding: 2, resource: { buffer: states[1 - index] } },
          ],
        }));
        const layout = gpu.createPipelineLayout({ bindGroupLayouts: [bindings] });
        const module = gpu.createShaderModule({ code: shader });
        const [simulation, triangles] = await Promise.all([
          gpu.createComputePipelineAsync({
            layout,
            compute: { module, entryPoint: 'simulate' },
          }),
          gpu.createRenderPipelineAsync({
            layout,
            vertex: { module, entryPoint: 'vertex' },
            fragment: {
              module,
              entryPoint: 'fragment',
              targets: [{
                format,
                blend: {
                  color: { srcFactor: 'src-alpha', dstFactor: 'one-minus-src-alpha' },
                  alpha: { srcFactor: 'one', dstFactor: 'one-minus-src-alpha' },
                },
              }],
            },
            primitive: { topology: 'triangle-list' },
          }),
        ]);
        if (disposed || device !== gpu) return;
        resize();
        updateColor();

        /** @type {GPURenderPassColorAttachment} */
        const attachment = {
          view: gpuContext.getCurrentTexture().createView(),
          clearValue: { r: 0, g: 0, b: 0, a: 0 },
          loadOp: 'clear',
          storeOp: 'store',
        };
        const renderPass = { colorAttachments: [attachment] };
        let current = 0;

        /** @param {number} time */
        const draw = (time) => {
          if (disposed || unavailable || reducedMotion.matches || document.hidden) return;
          if (time < nextTime) {
            frame = requestAnimationFrame(draw);
            return;
          }
          parameters[2] = lastTime ? Math.min((time - lastTime) / 1000, 0.05) : 0;
          lastTime = time;
          nextTime = time + FRAME_INTERVAL - ((time - nextTime) % FRAME_INTERVAL);
          try {
            gpu.queue.writeBuffer(uniforms, 0, parameters);
            const encoder = gpu.createCommandEncoder();
            const compute = encoder.beginComputePass();
            compute.setPipeline(simulation);
            compute.setBindGroup(0, groups[current]);
            compute.dispatchWorkgroups(Math.ceil(BOID_COUNT / 64));
            compute.end();
            current = 1 - current;
            attachment.view = gpuContext.getCurrentTexture().createView();
            const pass = encoder.beginRenderPass(renderPass);
            pass.setPipeline(triangles);
            pass.setBindGroup(0, groups[current]);
            pass.draw(3, BOID_COUNT);
            pass.end();
            gpu.queue.submit([encoder.finish()]);
            ready = true;
            frame = requestAnimationFrame(draw);
          } catch (error) {
            console.warn('WebGPU boids background unavailable.', error);
            unavailable = true;
            release();
          }
        };
        render = draw;
      } catch (error) {
        if (!disposed) {
          console.warn('WebGPU boids background unavailable.', error);
          unavailable = true;
        }
        release();
      } finally {
        initializing = false;
        if (!disposed) sync();
      }
    }

    const observer = new ResizeObserver(resize);
    observer.observe(canvas);
    window.addEventListener('resize', resize);
    document.addEventListener('visibilitychange', sync);
    reducedMotion.addEventListener('change', sync);
    darkMode.addEventListener('change', updateColor);
    sync();

    return () => {
      disposed = true;
      observer.disconnect();
      window.removeEventListener('resize', resize);
      document.removeEventListener('visibilitychange', sync);
      reducedMotion.removeEventListener('change', sync);
      darkMode.removeEventListener('change', updateColor);
      release();
    };
  });
</script>

<canvas bind:this={canvas} class:ready aria-hidden="true"></canvas>

<style>
  canvas {
    position: fixed;
    inset: 0;
    z-index: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
    opacity: 0;
  }

  canvas.ready {
    opacity: 1;
  }

  @media (prefers-reduced-motion: reduce) {
    canvas {
      display: none;
    }
  }
</style>
