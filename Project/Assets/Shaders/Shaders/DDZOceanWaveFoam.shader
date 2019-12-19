Shader "ZJY/Effect/OceanWaveFoam"
{
	Properties
	{
		[Space(18)]	
		_MainTex("Foam Mask", 2D) = "white"{}//foam area
		_NoiseTex ("Noise", 2D) = "white" {} //wave noise
		_FoamTex ("Foam Texture", 2D) = "white" {} // foam texture
		_WaveLine("Wave Line", 2D) = "white"{}
		
		[Space(18)]
		_Tint("Tint Color", Color) = (1,1,1,1)
		_FoamSpeed ("Foam Speed", Range(0,10) ) = 1
		_NoiseRange ("NoiseRange", float) = 6.43
	}	
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		Pass
		{
			//Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			fixed4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _FoamTex;
			float4 _FoamTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			sampler2D _WaveLine;
			float4 _WaveLine_ST;
			uniform half _FoamSpeed;
			half _NoiseRange;
			fixed3 _SceneDarkenColor;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4  color: Color; 
			};
		
			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD5;
				half3 worldViewDir:TEXCOORD6;
				float4 col:color;
				float4 uv1 : TEXCOORD7;


			};
 
			v2f vert(a2v v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.col=v.color;
				o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_FoamTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _FoamTex)+frac(half2(0,_Time.x*_FoamSpeed));

				o.uv1.xy=TRANSFORM_TEX(v.texcoord.xy, _MainTex);
				o.uv1.zw=TRANSFORM_TEX(v.texcoord.xy, _NoiseTex);
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
 

			fixed4 frag(v2f i) : SV_Target
			{
				
				fixed4 noise = tex2D(_NoiseTex, i.uv1.zw);
				fixed4 waveLine = tex2D(_WaveLine, i.uv.xy);

				fixed4 foam01= tex2D(_FoamTex, i.uv.xy);
				fixed4 foam02= tex2D(_FoamTex, i.uv.zw+fixed2(0.6,1));
				fixed4 foam=foam01*foam02;
				

				fixed4 color01Wave = tex2D(_WaveLine, fixed2(i.uv1.x,i.uv1.y)+fixed2(0,0)+noise.r*_NoiseRange);
				fixed4 color01 = tex2D(_MainTex, fixed2(i.uv1.x,i.uv1.y)+fixed2(0,0)+noise.r*_NoiseRange);
				fixed4 color01_foam = (tex2D(_MainTex, fixed2(i.uv1.x,i.uv1.y)+fixed2(0,0)+noise.r*_NoiseRange))*foam.r;
				color01_foam.a=color01.a*foam.a;
				fixed4 color02 = tex2D(_MainTex, fixed2(i.uv1.x+0.5f,i.uv1.y)+fixed2(0,0)+noise.r*_NoiseRange);
				fixed4 color02_foam = (tex2D(_MainTex, fixed2(i.uv1.x+0.5f,i.uv1.y)+fixed2(0,0)+noise.r*_NoiseRange))*foam.r;
				color02_foam.a=color02.a*foam.a;
				fixed4 finalCol;
				finalCol.rgb=(color01_foam.rgb+color01Wave.rgb)*_SceneDarkenColor;
				finalCol.a=(color01_foam.a+color01Wave.a)*_Tint.a*i.col.a;
				return finalCol;
			}
			ENDCG
		}
	}
	Fallback "ZJY/DDZReplaceDefault"
}