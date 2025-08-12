shader_type spatial;

uniform sampler2D base_texture;
uniform sampler2D secondary_texture;

uniform vec2 grid_size;
uniform vec4 test_tile; 
uniform float blend_width; 

uniform vec2 base_uv_scale; 
uniform vec2 secondary_uv_scale;

uniform float border_thickness;
uniform vec3 border_color; 

uniform vec2 grid_offset;

void fragment() {
    vec2 tile_size = 1.0 / grid_size;

    vec2 offset_uv = UV + grid_offset * tile_size;  

    vec2 tile_pos = floor(offset_uv / tile_size);


    vec2 local_uv = fract(offset_uv / tile_size);


    float is_border = step(local_uv.x, border_thickness) +
                      step(local_uv.y, border_thickness) +
                      step(1.0 - local_uv.x, border_thickness) +
                      step(1.0 - local_uv.y, border_thickness);

    is_border = clamp(is_border, 0.0, 1.0);


    vec2 test_tile_min = test_tile.xy / grid_size;         
    vec2 test_tile_max = (test_tile.xy + test_tile.zw) / grid_size; 

  
    vec2 blend_min = smoothstep(test_tile_min, test_tile_min + vec2(blend_width * tile_size), offset_uv);
    vec2 blend_max = smoothstep(test_tile_max - vec2(blend_width * tile_size), test_tile_max, offset_uv);

    float blend_factor = blend_min.x * blend_min.y * (1.0 - blend_max.x) * (1.0 - blend_max.y);

    vec2 base_uv = UV * base_uv_scale;
    vec2 secondary_uv = UV * secondary_uv_scale;

    vec4 base_color = texture(base_texture, base_uv);
    vec4 secondary_color = texture(secondary_texture, secondary_uv);

    vec4 final_color = mix(base_color, secondary_color, blend_factor);

    final_color.rgb = mix(final_color.rgb-0.1, (final_color.rgb-0.2), is_border);

    ALBEDO = final_color.rgb;
}