shader_type canvas_item;

// ---------- Controls ----------
uniform vec2  direction = vec2(1.0, 1.0);
uniform float speed      : hint_range(-2.0, 2.0) = 0.05;
uniform float scale      : hint_range(0.1, 10.0) = 1.0;
uniform bool  respect_alpha = true;

// Fire-ish palette
uniform vec3 fire1 : source_color = vec3(0.55, 0.00, 0.00); // deep dark red
uniform vec3 fire2 : source_color = vec3(0.80, 0.20, 0.00); // strong red-orange
uniform vec3 fire3 : source_color = vec3(1.00, 0.55, 0.00); // bright orange
uniform vec3 fire4 : source_color = vec3(1.00, 0.80, 0.20); // golden yellow


// Optional: make the tint a bit stronger over mid/high values of the gradient
uniform float band_softness : hint_range(0.0, 1.0) = 0.35;

vec3 fire_palette(float x) {
	vec3 c = mix(fire1, fire2, smoothstep(0.0, 0.25, x));
	c = mix(c, fire3,         smoothstep(0.25, 0.50, x));
	c = mix(c, fire4,         smoothstep(0.50, 0.75, x));
	c = mix(c, fire1,         smoothstep(0.75, 1.0, x));
	return c;
}

void fragment() {
	// Base
	vec4 base = texture(TEXTURE, UV);
	float a = base.a;

	// Direction & animated coordinate
	vec2 dir = direction;
	if (abs(dir.x) + abs(dir.y) < 1e-5) dir = vec2(1.0, 1.0);
	dir = normalize(dir);

	float u = dot(UV, dir) * scale + TIME * speed;
	float t = fract(u);

	// Fire color at this position
	vec3 fire_col = fire_palette(t);

	// Colorize (lerp) toward the fire color; preserves details but tints everything
	vec3 out_rgb = mix(base.rgb, fire_col, 1.0);

	// Keep original alpha exactly
	COLOR = vec4(out_rgb, a);
}
