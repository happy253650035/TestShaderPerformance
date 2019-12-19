Shader "RJ/Avatar" {
    Properties {
        _Maintex ("Maintex", 2D) = "white" {}
        _F_range ("F_range", Range(0, 5)) = 3.5
        _F_level ("F_level", Range(0, 3)) = 0
        _F_color ("F_color", Color) = (0.5,0.5,0.5,1)
        _SpecTex ("SpecTex", 2D) = "white" {}
        _SpecLevel ("SpecLevel", Range(0, 1)) = 1
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 200
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
//            #pragma only_renderers d3d9 d3d11 glcore gles gles3 
            #pragma target 3.0
            uniform sampler2D _Maintex; 
            uniform float4 _Maintex_ST;
            uniform float _F_range;
            uniform float _F_level;
            uniform float4 _F_color;
            uniform sampler2D _SpecTex; 
            uniform float4 _SpecTex_ST;
            uniform float _SpecLevel;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
//                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
//                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
                float node_801 = 0.5;
                float2 node_4921 = ((mul( UNITY_MATRIX_V, float4(i.normalDir,0) ).xyz.rgb.rg*node_801)+node_801);
                float4 _SpecTex_var = tex2D(_SpecTex,TRANSFORM_TEX(node_4921, _SpecTex));
                float4 _Maintex_var = tex2D(_Maintex,TRANSFORM_TEX(i.uv0, _Maintex));
                float3 finalColor = ((pow(1.0-max(0,dot(normalDirection, viewDirection)),_F_range)*_F_color.rgb*_F_level)+saturate((_Maintex_var.rgb/(1.0-(_SpecTex_var.rgb*_SpecLevel*_Maintex_var.a)))));
                fixed4 finalRGBA = fixed4(finalColor,1);
//                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
}
