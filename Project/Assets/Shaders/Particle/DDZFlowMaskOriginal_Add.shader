Shader "ZJY/Effect/Particles/DDZFlowMaskOriginal_Add" 
{
    Properties 
	{
		[HDR]
		_TintColFlow ("TintColorFlow", Color) = (0.5,0.5,0.5,1)
		[HDR]
		_TintCol ("TintColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Base(RGB)", 2D) = "white" {}
		_MaskTexFlow ("Mask(FLOW)", 2D) = "white" {}
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
			Tags { "LightMode" = "Always" }
			Blend SrcAlpha One	
			Cull Off
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"
			#pragma multi_compile OUT_OFF OUT_ON
            #pragma target 3.0
            uniform sampler2D _MainTex; 
			uniform float4 _MainTex_ST;
			uniform sampler2D _MaskTexFlow; 
			uniform float4 _MaskTexFlow_ST;
			uniform float _V_SPEED;
            uniform float _U_SPEED;
			fixed4 _TintColFlow;
			fixed4 _TintCol;

            struct VertexInput 
			{
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
				fixed4 color : COLOR;
				fixed3 normal:NORMAL;
            };

            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
				fixed4 color : COLOR;
				fixed3 worldNormal:NORMAL;
				fixed3 worldViewDir:TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
				o.uv0.xy=TRANSFORM_TEX(v.texcoord0, _MainTex);
                o.uv0.zw= (TRANSFORM_TEX(v.texcoord0, _MaskTexFlow)+frac((_V_SPEED*_Time.g)*float2(0,1)))+frac((_U_SPEED*_Time.g)*float2(1,0)-float2(0.5,0.5)+float2(0.5,0.5));
                o.pos = UnityObjectToClipPos(v.vertex );
				o.color = v.color;
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir=_WorldSpaceCameraPos-worldPos;
				o.worldNormal=normalize(UnityObjectToWorldNormal(v.normal)); 
                return o;
            }

            float4 frag(VertexOutput i) : COLOR 
			{
				float4 baseCol = tex2D(_MainTex,i.uv0.xy);
				baseCol.rgb*=_TintCol.rgb;
				float4 mask_time = _Time;
				float4 maskCol = tex2D(_MaskTexFlow,i.uv0.zw)*_TintColFlow*baseCol.a;
				//float4 finalColor;
				//finalColor.rgb=baseCol.rgb+maskCol.rgb;
				//finalColor.a=baseCol.rgb+maskCol.rgb;
				return fixed4(baseCol.rgb*_TintCol.a+maskCol.rgb,1*i.color.a);
			}
			ENDCG
        }
    }
	Fallback "Mobile/VertexLit"
}
