Shader "ZJY/Effect/Particles/DDZFlowMask_Add_dw" 
{
    Properties 
	{
		_TintCol ("TintColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Base(RGB)", 2D) = "white" {}
		_MaskTex ("Mask(FLOW)", 2D) = "white" {}
		_ROTATION ("ROTATION", Range(0, 3.14)) = 0
        _V_SPEED ("V_SPEED", Range(-5, 5)) = 0
        _U_SPEED ("U_SPEED", Range(-5, 5)) = -0.3123643
		[KeywordEnum(OFF,ON)]OUT("OutLine Mode",Float) = 1
		_FresnelColor("Fresnel Color",Color)=(1,1,1,1)
		_FresnelWidth ("Fresnel Width[0,10]", Range(0,10)) = 0.113
		_FresnelIntensity ("Fresnel Intensity[0,10]", Range(0,10)) = 2.35
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
			// Blend SrcAlpha OneMinusSrcAlpha
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
			uniform sampler2D _MaskTex; 
			uniform float4 _MaskTex_ST;
            uniform float _ROTATION;
            uniform float _V_SPEED;
            uniform float _U_SPEED;
			half _FresnelWidth;
			half _FresnelIntensity;
			fixed3 _FresnelColor;
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
                float2 uv0 : TEXCOORD0;
				fixed4 color : COLOR;
				fixed3 worldNormal:NORMAL;
				fixed3 worldViewDir:TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
				o.color = v.color;
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir=_WorldSpaceCameraPos-worldPos;
				o.worldNormal=normalize(UnityObjectToWorldNormal(v.normal)); 
                return o;
            }

            float4 frag(VertexOutput i) : COLOR 
			{
				#ifdef OUT_OFF
					fixed3 fresnel=fixed3(0,0,0);		
				#else
					//calculate fresnel
					fixed3 fresnel;
					float3 N_WorldNormal=normalize(i.worldNormal);
					float3 N_WorldViewDir=normalize(i.worldViewDir);
					fresnel = (pow (max (0.001, (1.0 - max (0.0, dot (N_WorldNormal, N_WorldViewDir)))),_FresnelWidth))*_FresnelIntensity*_FresnelColor;
				#endif
					float4 maskCol = tex2D(_MaskTex,TRANSFORM_TEX(i.uv0, _MaskTex));
					float mask_cos = cos(_ROTATION);
					float mask_sin = sin(_ROTATION);
					float4 mask_time = _Time;
					float2 mask_uv = mul((i.uv0+(_V_SPEED*mask_time.g)*float2(0,1))+(_U_SPEED*mask_time.g)*float2(1,0)-float2(0.5,0.5), float2x2( mask_cos, -mask_sin, mask_sin, mask_cos))+float2(0.5,0.5);
					float4 baseCol = tex2D(_MainTex,frac(TRANSFORM_TEX(mask_uv, _MainTex)));
					float4 finalColor;
					finalColor.rgb=(baseCol.rgb*maskCol.rgb)-(1-i.color.a)*0.6f;
					finalColor.a=(maskCol.a*baseCol.a)*i.color.a*0.8f;
					finalColor+=maskCol*0.05f;
					//finalColor.rgb+=fresnel;
					//finalColor.a*=maskCol.a;
				
					return finalColor;
				//return maskCol;
            }
            ENDCG
        }
    }
	Fallback "Mobile/VertexLit"
}
