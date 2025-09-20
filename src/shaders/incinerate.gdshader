shader_type canvas_item;

// Shader to fade pixels in a pattern:
//  [A B]
//  [C D]

// How long each pixel takes to go from alpha 1 -> 0.
uniform float fade_duration : hint_range(0.01, 1.0) = 1.0;

// Delay between A->D->B->C in each 2x2 set (in seconds).
uniform float step_delay : hint_range(0.0, 1.0) = 0.08;

// The current time in the animation, in seconds.
uniform float current_time : hint_range(0.0, 1.0) = 0.0;


void fragment()
{
    vec4 tex = texture(TEXTURE, UV);

    // Figure out which pixel we are in the texture (integer coords) and if they are odd/even.
    ivec2 px = ivec2(floor(UV / TEXTURE_PIXEL_SIZE));
    int x_odd = px.x & 1;
    int y_odd = px.y & 1;

    // Map 2x2 parities to the order: A(0,0)->0, D(1,1)->1, B(1,0)->2, C(0,1)->3
    int order = 0;
    if (x_odd == 1 && y_odd == 1) {
        order = 1; // D
    } else if (x_odd == 1 && y_odd == 0) {
        order = 2; // B
    } else if (x_odd == 0 && y_odd == 1) {
        order = 3; // C
    } // else A stays 0

    // Progress of fade for this pixel: 0 before its phase, 1 after duration.
    float phase = float(order) * step_delay;
    float p = clamp((current_time - phase) / fade_duration, 0.0, 1.0);

    // Fade alpha only; keep RGB intact.
    COLOR = vec4(tex.rgb, tex.a * (1.0 - p));

    // Then tint in orange as pixels fade out.
    COLOR.rgb += vec3(1.0, 0.5, 0.0) * p;
}
