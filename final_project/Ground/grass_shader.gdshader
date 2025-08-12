shader_type spatial;
uniform sampler2D grass_texture;
uniform float displacement_amount = 0.2;
uniform float alpha = 0.3;
uniform float transparency = 1.0;

void vertex() {
    vec2 uv = UV;
    float alpha_value = texture(grass_texture, uv).a;
    VERTEX += NORMAL * alpha_value * displacement_amount;
}

void fragment() {
    vec4 tex_color = texture(grass_texture, UV);
    ALBEDO = tex_color.rgb;
    float result = tex_color.a * transparency;
    float angle_factor = dot(NORMAL, VIEW);
    result *= clamp(angle_factor, 0.3, 1.0);
    if (result < alpha) {
        discard;
    }
    ALPHA = result;
}
