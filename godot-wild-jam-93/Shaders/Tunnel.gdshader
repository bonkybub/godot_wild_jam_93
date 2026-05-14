shader_type canvas_item;
// From FencerDevLof Tutorial

uniform vec2 resolution = vec2(1920.0, 1080.0);

uniform vec3 pointColor: source_color = vec3(1.0, 1.0, 1.0);
uniform float pointSize: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float layers: hint_range(1.0, 100.0, 1.0) = 50.0;
uniform float layerPoints: hint_range(10.0, 200.0, 0.1) = 100;
uniform float speed: hint_range(0.0, 10.0, 0.01) = 1.0;

vec2 SplitCircle(vec2 uv, float angle)
{
	float radius = length(uv);
	float theta = mod(atan(uv.x, uv.y), angle) -  angle / 2.0;
	return vec2(cos(theta), sin(theta)) * radius;
}

vec2 CurvePath(float depth)
{
	return vec2 (
		0.1 * cos(depth * 5.0),
		0.2 * sin(depth * 3.0)
	);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	
	vec3 color = vec3(0.0);
	float time = TIME * speed * 0.1;
	float size = pointSize / resolution.y;
	float angle = TAU /  layerPoints;
	vec2 shift = CurvePath(time);
	
	for (float i = 1.0; i<= layers; i++){
		float depth = 1.0 - i  / layers;
		depth -= mod(time, 2.0 / layers);
		float radius = 0.2 / pow(depth * 0.8 + 0.4, 2.0); // Makes the tunnel shape
		vec2 offset = CurvePath(time + depth) - shift;
		vec2 suv = SplitCircle(uv+ offset, angle);
		float dist = length(suv - vec2(radius, 0.0)) - size;
		vec3 c = pointColor * (mod(i, 2.0) * 0.3 + 0.7);
		color = mix(c * (1.0 - depth), color, smoothstep(0.0, size, dist)); 
	}
	
	COLOR = vec4(color, 1.0);
	
	
}
