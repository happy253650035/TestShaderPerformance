Shader "ZJY/Effect/Particles/DDZLightSweep_Add" 
{
    Properties 
	{
		
        _MainTex ("diffuse", 2D) = "white" {}
        _sweep_color ("sweep_color", Color) = (0.5,0.5,0.5,1)
        _ROTATION ("ROTATION", Range(0, 3.14)) = 0
        _V_SPEED ("V_SPEED", Range(-5, 5)) = 0
        _U_SPEED ("U_SPEED", Range(-5, 5)) = -0.3123643
    }
    SubShader 
	{
        Tags 
		{
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass 
		{
            Name "FORWARD"
            Blend SrcAlpha One	
            ZWrite Off
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; 
			uniform float4 _MainTex_ST;
            uniform float _ROTATION;
            uniform float _V_SPEED;
            uniform float _U_SPEED;
            uniform float4 _sweep_color;

            struct VertexInput 
			{
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
				fixed4 color : COLOR;
            };

            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
				fixed4 color : COLOR;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
				o.color = v.color;
                return o;
            }

            float4 frag(VertexOutput i) : COLOR 
			{
                float4 _diffuse_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float node_cos = cos(_ROTATION);
                float node_sin = sin(_ROTATION);
                float2 node_piv = float2(0.5,0.5);
                float4 node_time = _Time + _TimeEditor;
                float2 light_sweep_uv = mul((i.uv0+(_V_SPEED*node_time.g)*float2(0,1))+(_U_SPEED*node_time.g)*float2(1,0)-node_piv, float2x2( node_cos, -node_sin, node_sin, node_cos))+node_piv;
                float4 _light_sweep_var = tex2D(_MainTex,frac(TRANSFORM_TEX(light_sweep_uv, _MainTex)));
                float4 finalColor =i.color *_light_sweep_var*_sweep_color;
                return finalColor;
            }
            ENDCG
        }
    }
	Fallback "Mobile/VertexLit"
}
