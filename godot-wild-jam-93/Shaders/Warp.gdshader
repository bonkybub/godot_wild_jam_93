shader_type canvas_item;
// From FencerDevLof Tutorial

uniform vec2 resolution = vec2(1920.0, 1080.0);

uniform vec3 pointColor: source_color = vec3(1.0, 1.0, 1.0);
uniform float pointSize: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float layers: hint_range(1.0, 100.0, 1.0) = 50.0;
uniform float layerPoints: hint_range(10.0, 200.0, 0.1) = 100.0;
uniform float speed: hint_range(0.0, 10.0, 0.01) = 1.0;
uniform float dotJitter: hint_range(0.0, 8.0, 0.1) = 1.2;

uniform vec3 BgColor: source_color = vec3(0,0,0);
uniform float opacity: hint_range(0.0, 1.0, 0.01) = 0.0;

vec2 Hash22(vec2 p)
{
	p = vec2(
		dot(p, vec2(127.1, 311.7)),
		dot(p, vec2(269.5, 183.3))
	);
	return fract(sin(p) * 43758.5453) * 2.0 - 1.0;
}

vec2 CurvePath(float depth)
{
	return vec2(
		0.0 * cos(depth * 5.0),
		0.0 * sin(depth * 3.0)
	);
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	
	vec3 color = BgColor; // 0.02, 0, 0.02 (Dark purple)

	float time = TIME * speed * 0.2;
	float size = pointSize / resolution.y;
	float angle = TAU / layerPoints;

	vec2 shift = CurvePath(time);

	float scroll_chunk = 2.0 / layers;
	float scroll_amount = mod(time, scroll_chunk);
	float scroll_cycles = floor(time / scroll_chunk);
	
	for (float i = 1.0; i <= layers; i++) {
		float depth = 1.0 - i / layers;
		depth -= scroll_amount;

		float radius = 0.2 / pow(depth * 0.8 + 0.4, 2.0); // Makes the tunnel shape
		vec2 offset = CurvePath(time + depth) - shift;
		
		vec2 puv = uv + offset;

		float theta = atan(puv.x, puv.y);
		float wrapped_theta = mod(theta + PI, TAU);
		float base_point_index = floor(wrapped_theta / angle);

		float stable_layer_index = i - scroll_cycles * 2.0;

		float closest_dist = 9999.0;

		for (float neighbor = -1.0; neighbor <= 1.0; neighbor += 1.0) {
			float point_index = base_point_index + neighbor;

			float point_theta = (point_index + 0.5) * angle - PI;

			vec2 radial_dir = vec2(sin(point_theta), cos(point_theta));
			vec2 tangent_dir = vec2(radial_dir.y, -radial_dir.x);

			vec2 random_values = Hash22(vec2(stable_layer_index, point_index));

			vec2 random_offset = (
				radial_dir * random_values.x +
				tangent_dir * random_values.y
			) * size * dotJitter ;

			vec2 dot_center = radial_dir * radius + random_offset;

			float dist = length(puv - dot_center) - size;
			closest_dist = min(closest_dist, dist);
		}

		vec3 c = pointColor * (mod(i, 2.0) * 0.3 + 0.7);
		color = mix(c * (1.0 - depth), color, smoothstep(0.0, size, closest_dist));
	}
	
	COLOR = vec4(color, opacity);
}