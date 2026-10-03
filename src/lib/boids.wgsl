const NEIGHBOR_RADIUS = 0.23;
const SEPARATION_RADIUS = 0.055;
const FLOCK_NEIGHBORS = 8.0;
const MAX_STEERING = 0.035;
const MAX_ACCELERATION = 0.08;
const CAMERA_DISTANCE = 1.6;

struct Boid {
    position: vec4<f32>, // xyz: normalized volume position; w: individual phase
    velocity: vec4<f32>, // xyz: world-space velocity; w: preferred cruising speed
}

struct Parameters {
    world: vec3<f32>,
    delta: f32,
    tint: vec4<f32>,
    projection: vec2<f32>,
    pixelSize: f32,
    time: f32,
}

@group(0) @binding(0) var<uniform> parameters: Parameters;
@group(0) @binding(1) var<storage, read> previous: array<Boid>;
@group(0) @binding(2) var<storage, read_write> next: array<Boid>;

fn limit(value: vec3<f32>, maximum: f32) -> vec3<f32> {
    let squared = dot(value, value);
    if (squared > maximum * maximum) {
        return value * maximum * inverseSqrt(squared);
    }
    return value;
}

fn steer(direction: vec3<f32>, velocity: vec3<f32>, speed: f32) -> vec3<f32> {
    let squared = dot(direction, direction);
    if (squared < 0.000001) {
        return vec3<f32>(0.0);
    }
    return limit(direction * inverseSqrt(squared) * speed - velocity, MAX_STEERING);
}

@compute @workgroup_size(64)
fn simulate(@builtin(global_invocation_id) invocation: vec3<u32>) {
    let index = invocation.x;
    let count = arrayLength(&previous);
    if (index >= count) {
        return;
    }

    let boid = previous[index];
    let phase = boid.position.w;
    let time = parameters.time;
    let cruise = boid.velocity.w * (1.0 + 0.15 * sin(time * 0.22 + phase));
    var separation = vec3<f32>(0.0);
    var alignment = vec3<f32>(0.0);
    var cohesion = vec3<f32>(0.0);
    var neighbors = 0u;

    for (var other = 0u; other < count; other += 1u) {
        if (other == index) {
            continue;
        }
        let offset = (previous[other].position.xyz - boid.position.xyz) * parameters.world;
        let squared = dot(offset, offset);
        if (squared < NEIGHBOR_RADIUS * NEIGHBOR_RADIUS) {
            alignment += previous[other].velocity.xyz;
            cohesion += offset;
            neighbors += 1u;
            if (squared < SEPARATION_RADIUS * SEPARATION_RADIUS) {
                separation -= offset / max(squared, 0.000001);
            }
        }
    }

    var acceleration = steer(separation, boid.velocity.xyz, cruise) * 1.7;
    if (neighbors > 0u) {
        // Dense neighborhoods must not pull every bird into one shared swarm.
        let social = min(1.0, FLOCK_NEIGHBORS / f32(neighbors));
        acceleration += steer(alignment / f32(neighbors), boid.velocity.xyz, cruise) * (0.85 * social);
        acceleration += steer(cohesion / f32(neighbors), boid.velocity.xyz, cruise) * (0.45 * social);
    }

    // Each flow component is independent of its own axis: an evolving,
    // divergence-free field turns flocks without attracting them to one point.
    let p = boid.position.xyz * parameters.world;
    let flow = vec3<f32>(
        sin(p.y * 4.0 + time * 0.17) + cos(p.z * 5.0 - time * 0.11),
        sin(p.z * 4.0 + time * 0.13) - cos(p.x * 5.0 + time * 0.09),
        sin(p.x * 4.0 - time * 0.15) + cos(p.y * 5.0 + time * 0.07),
    );
    // Different phases, frequencies, and cruising speeds let birds leave a flock
    // instead of permanently locking to a shared heading.
    let wander = vec3<f32>(
        sin(time * (0.31 + phase * 0.013) + phase),
        cos(time * (0.23 + phase * 0.017) + phase * 2.4),
        sin(time * (0.19 + phase * 0.011) + phase * 4.1),
    );
    acceleration += steer(flow, boid.velocity.xyz, cruise) * 0.55;
    acceleration += steer(wander, boid.velocity.xyz, cruise) * 0.65;

    // Turn before the volume boundary; reflection handles any overshoot without
    // teleporting birds between near and far depth planes.
    let wall = boid.position.xyz - clamp(boid.position.xyz, vec3<f32>(-0.36), vec3<f32>(0.36));
    acceleration -= wall * parameters.world * 0.65;
    var velocity = boid.velocity.xyz + limit(acceleration, MAX_ACCELERATION) * parameters.delta;
    let squared = dot(velocity, velocity);
    if (squared > 0.00000001) {
        velocity *= cruise * inverseSqrt(squared);
    } else {
        velocity = vec3<f32>(cruise, 0.0, 0.0);
    }

    var position = boid.position.xyz + velocity * parameters.delta / parameters.world;
    for (var axis = 0u; axis < 3u; axis += 1u) {
        if (abs(position[axis]) > 0.5) {
            velocity[axis] = -sign(position[axis]) * abs(velocity[axis]);
            position[axis] = clamp(position[axis], -0.5, 0.5);
        }
    }
    next[index] = Boid(vec4<f32>(position, phase), vec4<f32>(velocity, boid.velocity.w));
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) opacity: f32,
}

@vertex
fn vertex(@builtin(vertex_index) vertexIndex: u32, @builtin(instance_index) instance: u32) -> VertexOutput {
    let triangle = array<vec2<f32>, 3>(
        vec2<f32>(5.0, 0.0),
        vec2<f32>(-3.0, 1.7),
        vec2<f32>(-3.0, -1.7),
    );
    let boid = previous[instance];
    let forward = normalize(boid.velocity.xyz);
    var side = cross(forward, vec3<f32>(0.0, 0.0, 1.0));
    if (dot(side, side) < 0.0001) {
        side = cross(forward, vec3<f32>(0.0, 1.0, 0.0));
    }
    side = normalize(side);
    let offset = (forward * triangle[vertexIndex].x + side * triangle[vertexIndex].y) * parameters.pixelSize;
    let point = boid.position.xyz * parameters.world + offset;
    let distance = CAMERA_DISTANCE + point.z;
    let perspective = CAMERA_DISTANCE / distance;
    var output: VertexOutput;
    output.position = vec4<f32>(point.xy * parameters.projection * CAMERA_DISTANCE, 0.0, distance);
    output.opacity = clamp(perspective * perspective * 0.65, 0.3, 1.25);
    return output;
}

@fragment
fn fragment(input: VertexOutput) -> @location(0) vec4<f32> {
    return vec4<f32>(parameters.tint.rgb, parameters.tint.a * input.opacity);
}
