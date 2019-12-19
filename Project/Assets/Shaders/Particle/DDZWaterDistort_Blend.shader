// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZJY/Effect/Particles/DDZWaterDistort_Blend" 
{
	Properties 
	{
		_DistortTex ("Noise Texture (RG)", 2D) = "white" {}
		_MainTex ("Main Texture ", 2D) = "white" {}
		_HeatTime  ("Heat Time", range (0,1.5)) = 1
		_HeatForce  ("Heat Force", range (0,0.1)) = 0.1
	}

	Category
	{
		Tags { "RenderType"="Opaque" }

		SubShader 
		{


			Pass 
			{
				Name "BASE"
				Tags { "LightMode" = "Always" }
			
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord: TEXCOORD0;
				};

				struct v2f 
				{
					float4 vertex : POSITION;
					//float4 uvgrab : TEXCOORD0;
					float2 uvmain : TEXCOORD1;
					float2 uvdistort:TEXCOORD2;
					fixed4 color : COLOR;
				};

				float _HeatForce;
				float _HeatTime;
				sampler2D _DistortTex;
				float4 _DistortTex_ST;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				
				

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					/*#if UNITY_UV_STARTS_AT_TOP
					float scale = -1.0;
					#else
					float scale = 1.0;
					#endif*/
					
					//o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
					//o.uvgrab.zw = o.vertex.zw;
					o.uvdistort = TRANSFORM_TEX( v.texcoord, _DistortTex );
					o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
					o.color = v.color;
					return o;
				}

				sampler2D _GrabTexture;

				half4 frag( v2f i ) : COLOR
				{

					//noise effect
					half4 offsetColor1 = tex2D(_DistortTex, i.uvdistort + _Time.xz*_HeatTime);
					half4 offsetColor2 = tex2D(_DistortTex, i.uvdistort - _Time.yx*_HeatTime);
					fixed2 disortUV=fixed2((offsetColor1.r + offsetColor2.r) * _HeatForce,(offsetColor1.g + offsetColor2.g) * _HeatForce);
					half4 finalCol = tex2D( _MainTex, i.uvmain+disortUV);
					//return finalCol;
					//return offsetColor2;
					return finalCol;
				}
				ENDCG
			}

		}
	}
	Fallback "Mobile/VertexLit"
}
