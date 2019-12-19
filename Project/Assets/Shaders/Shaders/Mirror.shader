Shader "ZJY/Mirror"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ReflectionTex ("ReflectionTex", 2D) = "white" {}
		_BlendIntensity("BlendIntensity",range(0,1))=0.5
	}
	SubShader
	{
		//Tags { "RenderType"="Opaque" }
		Tags 
		{
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
				
				half2 uv : TEXCOORD0;
			};

			struct v2f
			{
				
				half2 uv : TEXCOORD0;
				half4 vertex : SV_POSITION;
				half4 refl:TEXCOORD1;
			};

			sampler2D _MainTex;
			half4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.refl=ComputeScreenPos(o.vertex);
				return o;
			}
			
			sampler2D _ReflectionTex;
			fixed _BlendIntensity;

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed4 col2=tex2Dproj(_ReflectionTex,i.refl);
//				col = col2;
				if (col2.a > 0.8){
					col=lerp(col,col2,_BlendIntensity);
				}else{
					col = col;
				}

				return col;
			}
			ENDCG
		}
	}
}
