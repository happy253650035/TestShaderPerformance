
// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "ZJY/Scene/CustomAlphaBlended" 
{
	Properties 
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
	}

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Cull Off
		Lighting Off 
		ZWrite Off

		SubShader 
		{
			Pass 
			{

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
			
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;
				uniform fixed3 _SceneDarkenColor;
				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				
				};

				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color * _TintColor;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}

				fixed4 frag (v2f i) : SV_Target
				{
					fixed4 col = 2.0f * i.color * tex2D(_MainTex, i.texcoord);
					col.rgb*=_SceneDarkenColor;
					return col;
				}
				ENDCG
			}
		}
	}
}
