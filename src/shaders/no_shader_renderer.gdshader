shader_type canvas_item;

uniform sampler2D viewport_tex;

void fragment()
{
    // Sample viewport texture
    COLOR = texture(viewport_tex, UV);
}
