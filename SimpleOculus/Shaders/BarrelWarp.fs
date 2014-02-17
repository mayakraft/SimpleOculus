// shader from Oculus_SDK_Overview.pdf p.28
// GLSL translation http://www.mtbs3d.com/phpbb/viewtopic.php?f=140&t=17081

#version 120

uniform sampler2D Texture;
uniform vec2 LensCenter;
uniform vec2 ScreenCenter;
uniform vec2 Scale;
uniform vec2 ScaleIn;
uniform vec4 HmdWarpParam;

// Scales input texture coordinates for distortion.
vec2 HmdWarp(vec2 in01)
{
    vec2 theta = (in01 - LensCenter) * ScaleIn; // Scales to [-1, 1]
    float rSq = theta.x * theta.x + theta.y * theta.y;
    vec2 rvector = theta * (HmdWarpParam.x + HmdWarpParam.y * rSq +
                            HmdWarpParam.z * rSq * rSq +
                            HmdWarpParam.w * rSq * rSq * rSq);
    return LensCenter + Scale * rvector;
}

void main()
{
    vec2 tc = HmdWarp(gl_TexCoord[0].st);
    if (any(bvec2(clamp(tc,ScreenCenter-vec2(0.25,0.5), ScreenCenter+vec2(0.25,0.5)) - tc)))
    {
        gl_FragColor = vec4(vec3(0.0), 1.0);
        return;
    }
    
    gl_FragColor = texture2D(Texture, tc);
}