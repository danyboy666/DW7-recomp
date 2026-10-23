/* HD-2D colour grade: cool shadows, warm highlights, gentle contrast,
 * soft vignette. Runs on the composed game image (built-in header provides
 * v_uv, o, u_rcp, u_size, u_org and the u_tex sampler). */
void main()
{
    vec3 c = texelFetch(u_tex, ivec2(gl_FragCoord.xy) - u_org, 0).rgb;
    float l = dot(c, vec3(0.299, 0.587, 0.114));

    vec3 shadowTint = vec3(0.93, 0.97, 1.07);
    vec3 highTint   = vec3(1.07, 1.02, 0.96);
    c *= mix(shadowTint, highTint, smoothstep(0.0, 1.0, l));

    c = (c - 0.5) * 1.06 + 0.5;

    vec2 d = v_uv - 0.5;
    float vig = smoothstep(0.90, 0.30, length(d));
    c *= mix(0.84, 1.0, vig);

    o = vec4(clamp(c, 0.0, 1.0), 1.0);
}
