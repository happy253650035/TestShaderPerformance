Shader "ZJY/Scene/DDZUnlitTexture"
{
	Properties
	{
		_MainTex("Base 2D", 2D) = "white"{}
	}	
	SubShader
	{
		Pass
		{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed3 _SceneDarkenColor;
 
			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
		
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
 
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
 
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				color.rgb*=_SceneDarkenColor;
				return color;
			}
			ENDCG
		}
	}
	Fallback "ZJY/DDZReplaceDefault"
}