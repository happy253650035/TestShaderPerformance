// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZJY/Role/Fake_PBR(blinn phong)_role2Pass" 
{
	Properties 
	{
        _MainTex ("Base(RGB)", 2D) = "white" {}
		 _NormalMap ("Normal(RGB)", 2D) = "bump" {}
		 _MaskMap1 ("Mask1(R(Metallic) G(Smoothness) B(Alpha))", 2D) = "white" {}
		 _ReflectionCubeMap ("Reflection CubeMap", Cube) = "black" {}
		 _EnvColor ("EnvColor", Color) = (1,1,1,1)
		 _FresnelWidth ("Fresnel Width[0,10]", Range(0,10)) = 8
		 _FresnelIntensity ("Fresnel Intensity[0,5]", Range(0,5)) = 2
		 _Specular ("Specular(0,1)",Range(0,5)) = 5
		_SpecularGloss ("_SpecularGloss(0,100)", Range(0,100)) = 25
		_SpecularColor ("SpecularColor", Color) = (1,1,1,1)
		_SmoothnessRemappingLow("SmoothnessRemappingLow",Range(0.01,1))=0.01
		_SmoothnessRemappingHigh("SmoothnessRemappingHigh",Range(0.02,1))=1
		_MetallicRemappingLevelLow("MetallicRemappingLevelLow",Range(0.01,1))=0
        _MetallicRemappingLevelHigh("MetallicRemappingLevelHigh",Range(0,1))=1

		_SmoothnessRemappingLevelLow("SmoothnessRemappingLevelLow",Range(0,1))=0
        _SmoothnessRemappingLevelHigh("SmoothnessRemappingLevelHigh",Range(0,1))=1
		_MetallicRemappingLow("MetallicRemappingLow",Range(0.01,1))=0.01
		_MetallicRemappingHigh("MetallicRemappingHigh",Range(0.02,1))=1

		_GammaAdjust("GammaAdjust",Range(1,4))=4
	}
	
	SubShader
	{
		//在半透明之前渲染
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		/*Pass
		{
			ZWrite On
			ColorMask 0
		}*/
		

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			Cull Front
			//ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma target 3.0
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
			};
		
			struct v2f
			{
				half2 uv : TEXCOORD0;
				half4 vertex : SV_POSITION;
			};

			v2f vert (appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				half3 diffuseColor = albedo.rgb;
				fixed4 finalColor = 0;
				finalColor.rgb = diffuseColor;
				finalColor.a = albedo.a;	
				return finalColor;
			};
			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			Cull Back
			//ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half4 tangent : TANGENT;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				half2 uv : TEXCOORD0;
				half4 vertex : SV_POSITION;
				half3 worldViewDir:TEXCOORD1;
				half3 worldLightDir:TEXCOORD2;
				half3 SH_Light:TEXCOORD03;
				half3 worldNormal:TEXCOORD04;
				half3 worldTangent:TEXCOORD05;
				half3 worldBinormal:TEXCOORD06;
				half3 smoothness_metallic_fresnel:TEXCOORD07;
			};

			sampler2D _MainTex;
			half4 _MainTex_ST;
			sampler2D _NormalMap;
			sampler2D _MaskMap1;
			samplerCUBE _ReflectionCubeMap;
			half _FresnelWidth;
			half _FresnelIntensity;
			half _Specular;
			half _SpecularGloss;
			fixed3 _SpecularColor;
			fixed3 _EnvColor;
			fixed _SmoothnessRemappingLow;
			fixed _SmoothnessRemappingHigh;
			fixed _SmoothnessRemappingLevelLow;
            fixed _SmoothnessRemappingLevelHigh;

			fixed _MetallicRemappingLow;
			fixed _MetallicRemappingHigh;
            
			fixed _MetallicRemappingLevelLow;
            fixed _MetallicRemappingLevelHigh;
			fixed3 _ChangeColorPart01;
			fixed3 _ChangeColorPart02;
			fixed3 _ChangeColorPart03;

			half _GammaAdjust;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.worldTangent=normalize(UnityObjectToWorldDir(v.tangent.xyz)); 
				o.worldNormal=normalize(UnityObjectToWorldNormal(v.normal)); 
				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w; 
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir=normalize(_WorldSpaceCameraPos-worldPos);
				o.worldLightDir=_WorldSpaceLightPos0.xyz-(worldPos.xyz*_WorldSpaceLightPos0.z);
				o.SH_Light=ShadeSH9(float4(o.worldNormal,1));
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.smoothness_metallic_fresnel.x=(_SmoothnessRemappingLevelHigh-_SmoothnessRemappingLevelLow)/(_SmoothnessRemappingHigh-_SmoothnessRemappingLow);
				o.smoothness_metallic_fresnel.y=(_MetallicRemappingLevelHigh-_MetallicRemappingLevelLow)/(_MetallicRemappingHigh-_MetallicRemappingLow);
				o.smoothness_metallic_fresnel.z = pow (max (0.001, (1.0 - max (0.0, dot (o.worldNormal, o.worldViewDir)))),(_FresnelWidth+0.01))*_FresnelIntensity;
				return o;
			}
			

			#define DIFFUSE_MIP_LEVEL 9
			#define GLOSSY_MIP_COUNT 9

			half3 SampleTexCube(samplerCUBE cube,half3 normal,half mip)
			{
				return texCUBElod(cube,half4(normal,mip));
			}


			fixed4 frag (v2f i) : SV_Target
			{
				half3 N_WorldViewDir=i.worldViewDir;
				fixed4 diffuseCol = tex2D(_MainTex, i.uv);
				fixed3 mask1=tex2D(_MaskMap1,i.uv);
				half3x3 tangentToWorld = half3x3(i.worldTangent.x, i.worldBinormal.x, i.worldNormal.x,
				 i.worldTangent.y, i.worldBinormal.y, i.worldNormal.y,
			 	 i.worldTangent.z, i.worldBinormal.z, i.worldNormal.z
				);

				fixed3 bump=UnpackNormal(tex2D(_NormalMap,i.uv));
				 //bump tangentSpaceToWorldSpace
				bump=normalize( mul(tangentToWorld,bump));
				half3 worldRefl=reflect(N_WorldViewDir,normalize(bump));

				 //calculate fresnel 
				half fresnel = i.smoothness_metallic_fresnel.z;
//				fresnel = pow (max (0.001, (1.0 - max (0.0, dot (i.worldNormal, N_WorldViewDir)))),(_FresnelWidth+0.01))*_FresnelIntensity;

				 

				fixed3 samplerCubeRefCol=texCUBE(_ReflectionCubeMap,worldRefl).rgb;

				fixed3 albedoColor=diffuseCol;
				 
				half f_smoothness = i.smoothness_metallic_fresnel.x;
				half f_metallic = i.smoothness_metallic_fresnel.y;
				fixed3 directDiffuse=saturate(dot(bump,_WorldSpaceLightPos0));
				 //Blinn Phong 使用法线和半角向量做点积（lightDir+viewDir）
				fixed3 directSpecular = _Specular*((mask1.g)*pow(max(0.001,clamp(dot(bump,normalize(normalize(i.worldViewDir)+normalize(i.worldLightDir))),0,1)), _SpecularGloss))*_SpecularColor;
				fixed3 indirectSpecular_metallic = SampleTexCube(_ReflectionCubeMap,-worldRefl,9-((_SmoothnessRemappingLevelLow+clamp(mask1.g,_SmoothnessRemappingLow,_SmoothnessRemappingHigh)-_SmoothnessRemappingLow)*f_smoothness)*GLOSSY_MIP_COUNT)*(albedoColor+fixed3(0.03f,0.03f,0.03f))*_GammaAdjust*(mask1.r/(mask1.r+0.01f));
	
				fixed3 indirectSpecular_smoothness = SampleTexCube(_ReflectionCubeMap,-worldRefl,(1-((_SmoothnessRemappingLevelLow+clamp(mask1.g,_SmoothnessRemappingLow,_SmoothnessRemappingHigh)-_SmoothnessRemappingLow)*f_smoothness))*GLOSSY_MIP_COUNT)*fresnel*_GammaAdjust/2*(mask1.g/(mask1.g+0.5f));
				fixed3 indirectSpecular = indirectSpecular_metallic+indirectSpecular_smoothness;
				fixed3 indirectDiffuse = SampleTexCube(_ReflectionCubeMap,bump,DIFFUSE_MIP_LEVEL);
				 
				fixed3 diffuse=(_LightColor0.rgb *directDiffuse+albedoColor*i.SH_Light);
				fixed3 specular=(directSpecular+indirectSpecular);
				fixed alpha=diffuseCol.a;				 

				half3 color01_albedo=0;
				half3 color02_metallic=0;
				half3 color03_smoothness=0;
				half3 color04=0;
				color01_albedo=i.SH_Light*albedoColor;
				color02_metallic=indirectSpecular_metallic;
				color03_smoothness=indirectSpecular_smoothness;
				color04=lerp(i.SH_Light*albedoColor+directDiffuse*_LightColor0.rgb*albedoColor/2+directSpecular*_LightColor0.rgb,indirectSpecular_metallic*_EnvColor,(_MetallicRemappingLevelLow+clamp(mask1.r,_MetallicRemappingLow,_MetallicRemappingHigh)-_MetallicRemappingLow)*f_metallic)+indirectSpecular_smoothness*_EnvColor;
				return fixed4(color04,alpha);
			}
			ENDCG
		}

	}

	FallBack "ZJY/DDZReplaceDefault"
}