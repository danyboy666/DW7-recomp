/* HD-2D composite: sprite-preserving depth of field (blur 3D only), colour
 * grade (cool shadows, warm highlights), gentle contrast and a soft vignette.
 * u_mask is 1 where the last draw was 3D geometry (PGXP-proven). */
void main()
{
    vec3 sharp = texture(u_tex, v_uv).rgb;
    vec3 blur  = texture(u_blur, v_uv).rgb;
    float m    = clamp(texture(u_mask, v_uv).r, 0.0, 1.0);

    vec3 c = mix(sharp, blur, m * 0.75);

    float l = dot(c, vec3(0.299, 0.587, 0.114));
    c *= mix(vec3(0.93, 0.97, 1.07), vec3(1.07, 1.02, 0.96),
             smoothstep(0.0, 1.0, l));
    c = (c - 0.5) * 1.06 + 0.5;

    vec2 d = v_uv - 0.5;
    c *= mix(0.84, 1.0, smoothstep(0.90, 0.30, length(d)));

    o = vec4(clamp(c, 0.0, 1.0), 1.0);
}
