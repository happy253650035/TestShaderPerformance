Shader "ZJY/Effect/Particles/DDZLightBorder" 
{
    Properties 
	{
		_TintCol ("TintColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Base(RGB)", 2D) = "white" {}
		_FresnelColor("Fresnel Color",Color)=(1,1,1,1)
		_FresnelWidth ("Fresnel Width[0,10]", Range(0,10)) = 0.113
		_FresnelIntensity ("Fresnel Intensity[0,10]", Range(0,10)) = 2.35
		_LightDir("Light Direction" ,Vector)=(1,1,1,1)
		  _Cutoff ("Alpha Cut-Off Threshold", Range(0,1)) = 0.5
		
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
			ZWrite On
			ColorMask 0
			Offset 1, 1
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma target 3.0

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _Cutoff;
			
			
			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
			};
		
			struct v2f
			{
				half4 uv : TEXCOORD0;
				half4 vertex : SV_POSITION;
			};

			v2f vert (appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{	
				fixed4 albedo = tex2D(_MainTex, i.uv);
				clip(albedo.a - _Cutoff); //����AlphaTest     //clip������������Ϊ������������ƬԪ����
				return fixed4(0,0,0,1);
			};
			ENDCG
		}


        Pass 
		{
			Tags { "LightMode" = "Always" }
			Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"
			//#include "Lighting.cginc"
            #pragma target 3.0
            uniform sampler2D _MainTex; 
			uniform float4 _MainTex_ST;
			half _FresnelWidth;
			half _FresnelIntensity;
			fixed3 _FresnelColor;
			fixed4 _TintCol;
			fixed4 _LightDir;


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
				//fixed3 worldViewDir:TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 =TRANSFORM_TEX(v.texcoord0, _MainTex);
                o.pos = UnityObjectToClipPos(v.vertex );
				o.color = v.color;
				//float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				//o.worldViewDir=_WorldSpaceCameraPos-worldPos;
				o.worldNormal=normalize(UnityObjectToWorldNormal(v.normal)); 
                return o;
            }

            float4 frag(VertexOutput i) : COLOR 
			{
				//calculate fresnel
				fixed3 fresnel;
				fixed3 N_WorldNormal=normalize(i.worldNormal);
				//fixed3 N_WorldViewDir=normalize(i.worldViewDir);
				//fixed3 directDiffuse=saturate(dot(N_WorldNormal,normalize(_WorldSpaceLightPos0.rgb)));
				fresnel = (pow (max (0.001, (1.0 - max (0.0, dot (N_WorldNormal, fixed3(_LightDir.x,_LightDir.y,_LightDir.z))))),_FresnelWidth))*_FresnelIntensity*_FresnelColor;
				
				fixed4 mainCol = tex2D(_MainTex,i.uv0);
				fixed4 finalColor;
				finalColor.rgb=mainCol.rgb*_TintCol+fresnel;
				finalColor.a=mainCol.a;
					//finalColor.rgb+=fresnel;
					//finalColor.a*=maskCol.a;
				
				return finalColor;
				//return fixed4(_LightColor0.rgb,1);
					//return fixed4(finalColor.a,finalColor.a,finalColor.a,1l
            }
            ENDCG
        }
    }
	Fallback "Mobile/VertexLit"
}
