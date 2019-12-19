Shader "KWai/SelfColorForScene" {
	Properties {
		_Color("Color",Color) = (0,0,0,0)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_AlphaValue("Alpha Value", Range(0, 5.0)) = 1.0
		_RimColor("Rim Color", Color) = (0.5,0.5,0.5,1)
		_RimPower("Rim Power", Range(0, 1.5)) = 0.1
		_RimRange("Rim Range", Range(0, 5)) = 3.5
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 2
	}
	SubShader {  
		Tags{ "LightMode" = "ForwardBase" "Queue" = "Geometry" "RenderType" = "MGlow" }
		LOD 200

		Pass {
			Tags{ "LightMode" = "ForwardBase" "Queue" = "Geometry" "RenderType" = "MKGlow" }
			Cull [_Cull]

			//ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST;
			half _AlphaValue;
			fixed4 _Color;
			uniform fixed4 _RimColor;
			uniform half _RimPower;
			half _RimRange;
			uniform half _RimIntensity;

			struct a2v
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				fixed4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				half2 uv : TEXCOORD0;//纹理坐标
				half4 pos : SV_POSITION;//顶点位置
				half3 worldNormal : TEXCOORD1;
				half4 worldPos : TEXCOORD2;//世界坐标
			};

			v2f vert(a2v Input)
			{
				v2f Output;
				Output.pos = UnityObjectToClipPos(Input.vertex);
				Output.worldPos = mul(unity_ObjectToWorld, Input.vertex);
				Output.uv = Input.texcoord;
				Output.worldNormal = UnityObjectToWorldNormal(Input.normal);
				return Output;
			}

			fixed4 frag(v2f Input) : COLOR
			{
				fixed3 worldNormal = normalize(Input.worldNormal);
				fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - Input.worldPos.xyz);

				fixed4 mainCol = tex2D(_MainTex, Input.uv).rgba; 
				fixed3 finalColor = mainCol.rgb; 

                fixed3 Emissive = (pow(1.0-max(0,dot(worldNormal, worldViewDir)),_RimRange)*_RimColor.rgb*_RimPower);
                finalColor += Emissive;

				return fixed4(finalColor, mainCol.a*_AlphaValue)*_Color;
			}
			ENDCG
		}

	}
//	FallBack "Diffuse"
}
