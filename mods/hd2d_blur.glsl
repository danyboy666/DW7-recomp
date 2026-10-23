/* HD-2D depth-of-field blur pass: a soft 5-tap blur of the downscaled scene.
 * The grade pass mixes it in only where the mask marks 3D geometry, so pixel
 * art sprites stay crisp while the background recedes. */
void main()
{
    vec2 uv = v_uv;
    vec2 px = u_rcp * 1.5;
    vec3 c = texture(u_tex, uv).rgb * 0.36;
    c += texture(u_tex, uv + vec2( px.x, 0.0)).rgb * 0.16;
    c += texture(u_tex, uv + vec2(-px.x, 0.0)).rgb * 0.16;
    c += texture(u_tex, uv + vec2(0.0,  px.y)).rgb * 0.16;
    c += texture(u_tex, uv + vec2(0.0, -px.y)).rgb * 0.16;
    o = vec4(c, 1.0);
}
