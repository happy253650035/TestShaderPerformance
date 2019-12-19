Shader "KWai/LightSweep 1" {
    Properties {
        _diffuse_color ("diffuse_color", Color) = (0.5,0.5,0.5,1)
        _diffuse_light ("diffuse_light", Range(1, 2)) = 1
        _MainTex ("diffuse", 2D) = "white" {}
        _sweep_color ("sweep_color", Color) = (0.5,0.5,0.5,1)
        _light_sweep ("light_sweep", 2D) = "white" {}
        _ROTATION ("ROTATION", Range(0, 3.14)) = 0
        _V_SPEED ("V_SPEED", Range(-5, 5)) = 0
        _U_SPEED ("U_SPEED", Range(-5, 5)) = -0.3123643
        _LIGHT ("LIGHT", Range(0, 2)) = 1.92102

        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x 
            #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _light_sweep; uniform float4 _light_sweep_ST;
            uniform float _ROTATION;
            uniform float _V_SPEED;
            uniform float _U_SPEED;
            uniform float _LIGHT;
            uniform float4 _diffuse_color;
            uniform float4 _sweep_color;
            uniform float _diffuse_light;

            float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);  
            float2 _ClipArgs0 = float2(1000.0, 1000.0); 

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 worldPos : TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
                return o;
            }

            float4 frag(VertexOutput i) : COLOR {

                // Softness factor  
                float2 factor = (float2(1.0, 1.0) - abs(i.worldPos)) * _ClipArgs0;

                float4 _diffuse_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float node_cos = cos(_ROTATION);
                float node_sin = sin(_ROTATION);
                float2 node_piv = float2(0.5,0.5);
                float4 node_time = _Time + _TimeEditor;
                float2 light_sweep_uv = mul((i.uv0+(_V_SPEED*node_time.g)*float2(0,1))+(_U_SPEED*node_time.g)*float2(1,0)-node_piv, float2x2( node_cos, -node_sin, node_sin, node_cos))+node_piv;
                float4 _light_sweep_var = tex2D(_light_sweep,frac(TRANSFORM_TEX(light_sweep_uv, _light_sweep)));
                float3 emissive = ((_diffuse_var.rgb*_diffuse_var.a*_diffuse_color.rgb*_diffuse_light)+(_LIGHT*_light_sweep_var.rgb*_sweep_color.rgb));
                float3 finalColor = emissive;

                _diffuse_var.a *= clamp( min(factor.x, factor.y), 0.0, 1.0);

                return fixed4(finalColor,_diffuse_var.a);
            }
            ENDCG
        }
    }

}
