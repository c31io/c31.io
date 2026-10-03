struct Boid {
    position: vec2<f32>,
    velocity: vec2<f32>,
}

struct Parameters {
    world: vec2<f32>,
    delta: f32,
    count: u32,
    tint: vec4<f32>,
    clip: vec2<f32>,
    padding: vec2<f32>,
}

@group(0) @binding(0) var<uniform> parameters: Parameters;
@group(0) @binding(1) var<storage, read> previous: array<Boid>;
@group(0) @binding(2) var<storage, read_write> next: array<Boid>;

fn limit(value: vec2<f32>, maximum: f32) -> vec2<f32> {
    let squared = dot(value, value);
    if (squared > maximum * maximum) {
        return value * maximum * inverseSqrt(squared);
    }
    return value;
}

fn steer(direction: vec2<f32>, velocity: vec2<f32>) -> vec2<f32> {
    let squared = dot(direction, direction);
    if (squared < 0.000001) {
        return vec2<f32>(0.0);
    }
    return limit(direction * inverseSqrt(squared) * 0.045 - velocity, 0.025);
}

@compute @workgroup_size(64)
fn simulate(@builtin(global_invocation_id) invocation: vec3<u32>) {
    let index = invocation.x;
    if (index >= parameters.count) {
        return;
    }

    let boid = previous[index];
    var separation = vec2<f32>(0.0);
    var alignment = vec2<f32>(0.0);
    var cohesion = vec2<f32>(0.0);
    var neighbors = 0u;

    for (var other = 0u; other < parameters.count; other += 1u) {
        if (other == index) {
            continue;
        }
        // Shortest distance on a torus keeps flocks together across screen edges.
        var offset = previous[other].position - boid.position;
        offset = (offset - round(offset)) * parameters.world;
        let squared = dot(offset, offset);
        if (squared < 0.0144) {
            alignment += previous[other].velocity;
            cohesion += offset;
            neighbors += 1u;
            if (squared < 0.0009) {
                separation -= offset / max(squared, 0.000001);
            }
        }
    }

    var acceleration = steer(separation, boid.velocity) * 1.4;
    if (neighbors > 0u) {
        acceleration += steer(alignment / f32(neighbors), boid.velocity) * 0.8;
        acceleration += steer(cohesion / f32(neighbors), boid.velocity) * 0.6;
    }

    var velocity = limit(boid.velocity + acceleration * parameters.delta, 0.045);
    let squared = dot(velocity, velocity);
    if (squared < 0.000625) {
        if (squared > 0.00000001) {
            velocity *= 0.025 * inverseSqrt(squared);
        } else {
            velocity = vec2<f32>(0.025, 0.0);
        }
    }

    next[index].velocity = velocity;
    next[index].position = fract(boid.position + velocity * parameters.delta / parameters.world + vec2<f32>(1.0));
}

@vertex
fn vertex(@builtin(vertex_index) vertexIndex: u32, @builtin(instance_index) instance: u32) -> @builtin(position) vec4<f32> {
    let triangle = array<vec2<f32>, 3>(
        vec2<f32>(5.0, 0.0),
        vec2<f32>(-3.0, 1.7),
        vec2<f32>(-3.0, -1.7),
    );
    let boid = previous[instance];
    let forward = normalize(boid.velocity);
    let side = vec2<f32>(-forward.y, forward.x);
    let offset = forward * triangle[vertexIndex].x + side * triangle[vertexIndex].y;
    return vec4<f32>(boid.position * 2.0 - 1.0 + offset * parameters.clip, 0.0, 1.0);
}

@fragment
fn fragment() -> @location(0) vec4<f32> {
    return parameters.tint;
}
