// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Simplified Bumped Specular shader. Differences from regular Bumped Specular one:
// - no Main Color nor Specular Color
// - specular lighting directions are approximated per vertex
// - writes zero to alpha channel
// - Normalmap uses Tiling/Offset of the Base texture
// - no Deferred Lighting support
// - no Lightmap support
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

Shader "KWai/Bumped Specular(Blur and Color)" 
{
Properties
{
    _Shininess ("Shininess", Range (0.03, 1)) = 0.078125
    _MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
    [NoScaleOffset] _BumpMap ("Normalmap", 2D) = "bump" {}
    _MainTex_Blur ("Blur Base (RGB) Gloss (A)", 2D) = "white" {}
    [NoScaleOffset] _BumpMap_Blur ("Blur Normalmap", 2D) = "bump" {}
    _Color("Color",Color) = (1,1,1,0)
    _BlurValue("Blur Value",Range (0, 1)) = 0
}
SubShader 
{
    Tags { "RenderType"="Opaque" }
    LOD 250

CGPROGRAM
#pragma surface surf MobileBlinnPhong finalcolor:mycolor MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview interpolateview

sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _MainTex_Blur;
sampler2D _BumpMap_Blur;
half _Shininess;
half _BlurValue;
half4 _Color;

struct Input
{
    float2 uv_MainTex;
};

inline fixed4 LightingMobileBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
{
    fixed diff = max (0, dot (s.Normal, lightDir));
    fixed nh = max (0, dot (s.Normal, halfDir));
    fixed spec = pow (nh, s.Specular*128) * s.Gloss;

    fixed4 c;
    c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
    UNITY_OPAQUE_ALPHA(c.a);
    return c;
}

// final color处理函数
void mycolor (Input IN, SurfaceOutput o, inout fixed4 color) {
    color.rgb = lerp (color.rgb, color.rgb * _Color.rgb, _BlurValue);
}

void surf (Input IN, inout SurfaceOutput o) 
{
	half4 tex = tex2D( _MainTex, IN.uv_MainTex);
    half4 tex_blur = tex2D( _MainTex_Blur, IN.uv_MainTex);

    o.Albedo = (tex.rgb*(1 - _BlurValue) + tex_blur.rgb*_BlurValue);
    o.Gloss = tex.a;
    o.Alpha = tex.a;
    o.Specular = _Shininess;
    o.Normal = UnpackNormal (tex2D(_BumpMap, IN.uv_MainTex))*(1 - _BlurValue) + UnpackNormal (tex2D(_BumpMap_Blur, IN.uv_MainTex))*_BlurValue;
}
ENDCG
}

FallBack "ZJY/DDZReplaceDefault"
}
