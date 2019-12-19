/*
   Mix by mask3000
   Last Edit Date : 2018.1.4
*/
Shader "Custom/NPRAlpha" {
	Properties {
		_Color("Color",Color) = (0,0,0,0)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_AlphaValue("Alpha Value", Range(0, 5.0)) = 1.0
		_LightingMap("LightingMap 透明通道--亮度值反应高光出现的可能性",2D) = "grey"{}
		_RimColor("Rim Color", Color) = (0.5,0.5,0.5,1)
		_RimPower("Rim Power", Range(0, 1.5)) = 0.1
		_RimRange("Rim Range", Range(0, 5)) = 3.5
		_MGlowTex("Glow Texture", 2D) = "black" {}
		_MGlowTexColor("Glow Texture Color", Color) = (1,1,1,1)
		_MGlowTexStrength("Glow Texture Strength ", Range(0.0,10.0)) = 1.0
		_Spec1Pow("Spec1 Strength",Range(0,20)) = 0
		_Spec1Color("Spec1 Color",Color) = (1,1,1,1)
		_LightSpecColor("Spec Light Color",Color) = (1,1,1,1)
		_SpecMulti("Spec Strength",Range(0,10)) = 0
		_Shininess("Spec Area", Range(0.01,10)) = 1.0
		_Atten("Atten",Range(0,1)) = 0.5
	}
	SubShader {  
		Tags{ "LightMode" = "ForwardBase" "Queue" = "Transparent" "RenderType" = "MGlow" }
		LOD 200

		Pass {
			Tags{ "LightMode" = "ForwardBase" "Queue" = "Transparent" "RenderType" = "MKGlow" }
			Cull Back

			//ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"  

			sampler2D _MainTex;
			half4 _MainTex_ST;
			half _AlphaValue;
			sampler2D _LightingMap;
			half4 _LightingMap_ST;
			fixed4 _Color;
			uniform fixed4 _RimColor;
			uniform half _RimPower;
			half _RimRange;
			uniform half _RimIntensity;
			sampler2D _MGlowTex;
			half _MGlowTexStrength;
			fixed4 _MGlowTexColor;
			sampler2D _SpecTex;
			half _Spec1Pow;
			fixed4 _Spec1Color;
			fixed4 _LightSpecColor;
			half _SpecMulti;
			half _Shininess;
			half _Atten;

			struct a2v
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 texcoord : TEXCOORD0;
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
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(Input.worldPos));
				fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - Input.worldPos.xyz);
//				UNITY_LIGHT_ATTENUATION(atten, Input, Input.worldPos);
				fixed atten = _Atten;

   				fixed4 lightMapColor = tex2D(_LightingMap, Input.uv).rgba;
				fixed4 mainCol = tex2D(_MainTex, Input.uv).rgba; 

				fixed3 finalColor; 


				half value = 0.5;
                half2 Spec1Uv = ((mul( UNITY_MATRIX_V, half4(worldNormal,0) ).xyz.rgb.rg*value)+value);
                half4 _SpecTex_var = tex2D(_MainTex,TRANSFORM_TEX(Spec1Uv, _MainTex));
                half4 _Maintex_var = tex2D(_MainTex,TRANSFORM_TEX(Input.uv, _MainTex));

                fixed3 Emissive = (pow(1.0-max(0,dot(worldNormal, worldViewDir)),_RimRange)*_RimColor.rgb*_RimPower);
                finalColor = Emissive;

				/*------------------------------Spec----------------------------------------*/		
				fixed3 Spec1 = saturate((_Maintex_var.rgb/(1.0-(_SpecTex_var.rgb*_Spec1Color.rgb*_Spec1Pow*lightMapColor.a))));
                finalColor += Spec1;

				half3 halfView = worldViewDir + normalize(_WorldSpaceLightPos0.xyz);
				halfView = normalize(halfView);
				half shinPow = pow(max(dot(worldNormal, halfView), 0), _Shininess);
				fixed3 specColor = _SpecMulti * _LightSpecColor.xyz * shinPow * atten * lightMapColor.a;
				finalColor += specColor;

				fixed3 d = tex2D(_MGlowTex, Input.uv) *_MGlowTexColor;
				finalColor.rgb += (d.rgb * _MGlowTexStrength);

				return fixed4(finalColor, mainCol.a*_AlphaValue)*_Color;
			}
			ENDCG
		}

	}
}
