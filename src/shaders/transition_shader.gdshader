shader_type canvas_item;

uniform float clear_progress : hint_range(0.0, 1.0) = 0.0; // 0 -> 1 where 1 is fully cleared.

void fragment()
{
    vec4 tex_color = texture(TEXTURE, UV);

	// Figure out which pixel we are in the texture (integer coords) and if they are odd/even.
    ivec2 px = ivec2(floor(UV / TEXTURE_PIXEL_SIZE));
    int x_odd = px.x & 1;
    int y_odd = px.y & 1;
    
    float sweepA = (UV.x + UV.y) * 0.5;
	float sweepB = (UV.x + (1.0 - UV.y)) * 0.5;
	float sweepC = ((1.0 - UV.x) + UV.y) * 0.5;
	float sweepD = ((1.0 - UV.x) + (1.0 - UV.y)) * 0.5;

	float sweep = sweepA;
    if (x_odd == 1 && y_odd == 1) {
        sweep = sweepB;
    } else if (x_odd == 1 && y_odd == 0) {
        sweep = sweepC;
    } else if (x_odd == 0 && y_odd == 1) {
        sweep = sweepD;
    }
    
    if (sweep <= clear_progress) {
        // Cleared pixel → make transparent
        COLOR = vec4(tex_color.rgb, 0.0);
    } else {
        // Black with full alpha.
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    }
}
