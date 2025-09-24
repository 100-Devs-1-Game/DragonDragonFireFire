shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform bool is_active = false; // To be hidden after progress reaches 1.0

const float HALF_WIDTH = 0.5; // Thickness of the band.
const float INTENSITY  = 1.0; // Brightness of the highlight.

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Fixed 45° direction.
    vec2 dir = normalize(vec2(1.0, 1.0));

    // Project UV onto the sweep axis; range ~[0, sqrt(2)].
    float proj = dot(UV, dir);

    // Map progress [0..1] to projection range [0..sqrt(2)].
    float center = progress * 1.41421356;

    // Distance from band center.
    float d = abs(proj - center);

    // Soft band: 1.0 at center, fades to 0 by HALF_WIDTH.
    float band = 1.0 - smoothstep(0.0, HALF_WIDTH, d);

    // Additive-style highlight respecting sprite alpha.
    float strength = band * INTENSITY * tex.a;
    vec3 out_rgb = clamp(tex.rgb + vec3(strength), 0.0, 1.0);
    COLOR = vec4(out_rgb, tex.a);

    // If inactive, just ignore everything.
    if (!is_active)
    {
        COLOR = tex;
    }
}
