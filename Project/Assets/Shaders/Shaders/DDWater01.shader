// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZJY/Effect/Water01" 
{
	Properties 
	{
		_NormalMainMap ("NormalMain(RGB)", 2D) = "bump" {}
		_NormalDetailMap ("NormalDetail(RGB)", 2D) = "bump" {}
		[Space(18)]
		_ReflectionCubeMap ("Reflection CubeMap", Cube) = "black" {}
		_ReflectionIntensity ("Refcletion Intensity", Range(0,1) ) = 0.5
		_EnvColor ("EnvColor", Color) = (1,1,1,1)
		_FresnelWidth ("Fresnel Width[0,20]", Range(0,20)) = 8
		_FresnelIntensity ("Fresnel Intensity[0,5]", Range(0,5)) = 2
		[Space(18)]
		_RefractionIntensity("Refraction Inensity",Range(0,5))=1
		[Space(18)]
		_Specular ("Specular(0,1)",Range(0,5)) = 5
		_SpecularGloss ("SpecularGloss(0,100)", Range(0,1000)) = 25
		_SpecularColor ("SpecularColor", Color) = (1,1,1,1)
		[Space(18)]
		_WaveMainSpeed ("WaveMain Speed", Range(0,10) ) = 1
		_WaveDetailSpeed ("WaveDetail Speed", Range(0,10) ) = 1
		_WaveMainIntensity ("WaveMain Intensity", Range(0,10) ) = 1
		_WaveDetailIntensity ("WaveDetail Intensity", Range(0,10) ) = 1
		_WaveShadowIntensity("WaveShadow Intensity",Range(0,5))=1








		//_MainFoamOpacity ("Main Foam Opacity", Range(0, 1)) = 0.8737864
		//_MainFoamIntensity ("Main Foam Intensity", Range(0, 10)) = 3.84466
		// _MainFoamSpeed ("Main Foam Speed", Float ) = 0.1
		//   _MainFoamScale ("Main Foam Scale", Float ) = 40
		// _FoamTexture ("FoamTexture", 2D) = "white" {}
		// _DistortionTexture ("DistortionTexture", 2D) = "white" {}
		//  _WavesDirection ("Waves Direction", Range(0, 360)) = 0
		  // _WavesAmplitude ("Waves Amplitude", Range(0, 10)) = 4.980582
		
	}
	
	SubShader
	{
		//在半透明之前渲染
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

		//GrabPass{}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			Cull Back
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
				half4 uv : TEXCOORD0;
				half4 tangent : TANGENT;
				half3 normal : NORMAL;
				float4  color: Color; 
				
			};

			struct v2f
			{
				half4 uv : TEXCOORD0;
				
				half4 vertex : SV_POSITION;
				half3 worldViewDir:TEXCOORD1;
				half3 worldLightDir:TEXCOORD2;
				half2 uv1 : TEXCOORD3;
				//half3 SH_Light:TEXCOORD03;
				half3 worldNormal:TEXCOORD04;
				half3 worldTangent:TEXCOORD05;
				half3 worldBinormal:TEXCOORD06;
				float4 screenPos:TEXCOORD7;
				float4 col:color;
			};


			uniform float _WavesDirection;
			 uniform float _WavesAmplitude;


			sampler2D _GrabTexture;
			sampler2D _CameraDepthTexture;
			sampler2D _NormalMainMap;
			half4 _NormalMainMap_ST;
			sampler2D _NormalDetailMap;
			half4 _NormalDetailMap_ST;
			uniform half _WaveMainSpeed;
			uniform half _WaveDetailSpeed;
			uniform half _WaveMainIntensity;
			uniform half _WaveDetailIntensity;
			half _RefractionIntensity;
			
			samplerCUBE _ReflectionCubeMap;
			half _FresnelWidth;
			half _FresnelIntensity;
			half _Specular;
			half _SpecularGloss;
			fixed3 _SpecularColor;
			fixed3 _EnvColor;
			uniform half _ReflectionIntensity;
			uniform half _WaveShadowIntensity;
			fixed3 _SceneDarkenColor;
			//uniform sampler2D _DistortionTexture; 
			//uniform float4 _DistortionTexture_ST; 
			//uniform sampler2D _FoamTexture;
			//uniform float4 _FoamTexture_ST;
			//uniform float _WavesSpeed;

			//half _GammaAdjust;
			//uniform float _MainFoamSpeed;
			// uniform float _MainFoamScale;
			 // uniform float _MainFoamOpacity;
			 //uniform float _MainFoamIntensity;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.col=v.color;
				o.worldTangent=normalize(UnityObjectToWorldDir(v.tangent.xyz)); 
				o.worldNormal=normalize(UnityObjectToWorldNormal(v.normal)); 
				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w; 
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir=WorldSpaceViewDir(v.vertex);
				o.worldLightDir=WorldSpaceLightDir(v.vertex);
				//o.SH_Light=ShadeSH9(float4(o.worldNormal,1));
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos=ComputeScreenPos(o.vertex);
				//COMPUTE_EYEDEPTH函数，将z分量范围[-Near,Far]转换为[Near,Far]
				COMPUTE_EYEDEPTH(o.screenPos.z);
				o.uv.xy = TRANSFORM_TEX(v.uv.xy, _NormalMainMap)*_WaveMainIntensity+frac(half2(_Time.x*_WaveMainSpeed,0));
				o.uv.zw = TRANSFORM_TEX(v.uv.yx, _NormalDetailMap)*_WaveMainIntensity/2-frac(half2(_Time.x*_WaveMainSpeed,0));
				o.uv1 = TRANSFORM_TEX(v.uv.yx, _NormalDetailMap)*_WaveDetailIntensity-frac(half2(_Time.x*_WaveDetailSpeed,0));
				//o.smoothness_metallic_fresnel.x=(_SmoothnessRemappingLevelHigh-_SmoothnessRemappingLevelLow)/(_SmoothnessRemappingHigh-_SmoothnessRemappingLow);
				//o.smoothness_metallic_fresnel.y=(_MetallicRemappingLevelHigh-_MetallicRemappingLevelLow)/(_MetallicRemappingHigh-_MetallicRemappingLow);
				//o.smoothness_metallic_fresnel.z = pow (max (0.001, (1.0 - max (0.0, dot (o.worldNormal, o.worldViewDir)))),(_FresnelWidth+0.01))*_FresnelIntensity;
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
				half3 N_WorldViewDir=normalize(i.worldViewDir);
				//fixed4 diffuseCol = tex2D(_MainTex, i.uv);
				//fixed3 mask1=tex2D(_MaskMap1,i.uv);
				half3x3 tangentToWorld = half3x3(i.worldTangent.x, i.worldBinormal.x, i.worldNormal.x,
				 i.worldTangent.y, i.worldBinormal.y, i.worldNormal.y,
			 	 i.worldTangent.z, i.worldBinormal.z, i.worldNormal.z
				);
				fixed4 col1 = tex2D(_NormalMainMap, i.uv.xy);
				fixed4 col2 = tex2D(_NormalMainMap, i.uv.zw);
                fixed4 col3 = tex2D(_NormalDetailMap, i.uv1);
                //fixed4 col=col1+col2+col3;
                fixed4 col=(col1+col2+col3)/3;





				fixed3 bumpT=UnpackNormal(col);
				//fixed3 bumpT_detail=UnpackNormal(col5);

				 //bump tangentSpaceToWorldSpace
			    fixed3	bump=normalize( mul(tangentToWorld,bumpT));
				//fixed3	bump_detail=normalize( mul(tangentToWorld,bumpT_detail));
				half3 worldRefl=reflect(N_WorldViewDir,bump);

				 //calculate fresnel 
				//half fresnel = i.smoothness_metallic_fresnel.z;
				fixed fresnel = 1-(pow (max (0.001, (1.0 - max (0.0, dot (i.worldNormal, N_WorldViewDir)))),(_FresnelWidth+0.01))*_FresnelIntensity);

				 

				//fixed3 samplerCubeRefCol=texCUBE(_ReflectionCubeMap,worldRefl).rgb;

				//fixed3 albedoColor=diffuseCol;
				 
			//	half f_smoothness = i.smoothness_metallic_fresnel.x;
				//half f_metallic = i.smoothness_metallic_fresnel.y;
				fixed3 directDiffuse=saturate(dot(bump,_WorldSpaceLightPos0));
				 //Blinn Phong 使用法线和半角向量做点积（lightDir+viewDir）
				fixed3 directSpecular = _Specular*(pow(max(0.001,clamp(dot(bump,normalize(normalize(i.worldViewDir)+normalize(i.worldLightDir))),0,1)), _SpecularGloss))*_SpecularColor;
				//fixed3 indirectSpecular_metallic = SampleTexCube(_ReflectionCubeMap,-worldRefl,9-((_SmoothnessRemappingLevelLow+clamp(mask1.g,_SmoothnessRemappingLow,_SmoothnessRemappingHigh)-_SmoothnessRemappingLow)*f_smoothness)*GLOSSY_MIP_COUNT)*(albedoColor+fixed3(0.03f,0.03f,0.03f))*_GammaAdjust*(mask1.r/(mask1.r+0.01f));
	
				//fixed3 indirectSpecular_smoothness = SampleTexCube(_ReflectionCubeMap,-worldRefl,(1-((_SmoothnessRemappingLevelLow+clamp(mask1.g,_SmoothnessRemappingLow,_SmoothnessRemappingHigh)-_SmoothnessRemappingLow)*f_smoothness))*GLOSSY_MIP_COUNT)*fresnel*_GammaAdjust/2*(mask1.g/(mask1.g+0.5f));
				//fixed3 indirectSpecular = indirectSpecular_metallic+indirectSpecular_smoothness;
				//fixed3 indirectDiffuse = SampleTexCube(_ReflectionCubeMap,bump,DIFFUSE_MIP_LEVEL);
				 
			//	fixed3 diffuse=(_LightColor0.rgb *directDiffuse+albedoColor*i.SH_Light);
			//	fixed3 specular=(directSpecular+indirectSpecular);
				//fixed alpha=mask1.b;				

				//half3 color01_albedo=0;
				//half3 color02_metallic=0;
				//half3 color03_smoothness=0;
				//half3 color04=0;
				//color01_albedo=i.SH_Light*albedoColor;
				//color02_metallic=indirectSpecular_metallic;
				//color03_smoothness=indirectSpecular_smoothness;
				//color04=lerp(i.SH_Light*albedoColor+directDiffuse*_LightColor0.rgb*albedoColor/2+directSpecular*_LightColor0.rgb,indirectSpecular_metallic*_EnvColor,(_MetallicRemappingLevelLow+clamp(mask1.r,_MetallicRemappingLow,_MetallicRemappingHigh)-_MetallicRemappingLow)*f_metallic)+indirectSpecular_smoothness*_EnvColor;
				//return fixed4(color04,alpha);
				//return fixed4(SampleTexCube(_ReflectionCubeMap,-worldRefl,1),1);
				//return fixed4(SampleTexCube(_ReflectionCubeMap,-worldRefl,1)*0.8f,0.8f);


				//获取深度纹理,通过LinearEyeDepth函数将采样的深度纹理值转换为对应的深度范围[Near~Far] 
				//float sceneZ = max(0,LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)))) - _ProjectionParams.g);
				//float partZ=max(0,i.screenPos.z - _ProjectionParams.g);
				//float distance =1 - saturate(sceneZ - i.screenPos.z);

				//float4 node_8260 = _Time;

				//rotateuv
				//float waveDirection = (_WavesDirection/57.0);
               // float node_9794_spd = 1.0;
               // float node_9794_cos = cos(node_9794_spd*waveDirection);
              //  float node_9794_sin = sin(node_9794_spd*waveDirection);
				//float2 node_9794_piv = float2(0.5,0.5);
              //  float2 node_9794 = (mul(i.uv-node_9794_piv,float2x2( node_9794_cos, -node_9794_sin, node_9794_sin, node_9794_cos))+node_9794_piv);
              //  float4 _Gradient = tex2D(_DistortionTexture,TRANSFORM_TEX(node_9794, _DistortionTexture));
              //  float node_5335 = sin(((node_8260.g*_WavesSpeed)-(_Gradient.b*(_WavesAmplitude*30.0))));


				//  float node_6450 = (_MainFoamSpeed*0.15);
				//float4 node_4283 = _Time;
               // float2 node_6798 = ((float2(node_6450,node_6450)*node_4283.g)+(i.uv/4*_MainFoamScale));
				// float4 _FoamNoise = tex2D(_FoamTexture,TRANSFORM_TEX(node_6798, _FoamTexture));
				// float node_9706 = ((1.0 - saturate((pow(saturate(saturate((sceneZ-partZ)/((node_5335*0.1+0.2)*(_FoamNoise.r*_MainFoamIntensity)))),15.0)/0.1)))*_MainFoamOpacity);


				// float node_9706 = 1.0 - saturate(saturate((sceneZ+noise(3))-partZ));























				float2 offset_xy=dot(bumpT,float3(0,1,0));
                i.screenPos.xy+=offset_xy*_RefractionIntensity;
				fixed4 gcol=tex2Dproj(_GrabTexture,i.screenPos);
				//fixed4  aa=tex2D(_GrabTexture,i.uv);
				//return fixed4((gcol.rgb+SampleTexCube(_ReflectionCubeMap,-worldRefl,1))/2+directSpecular,0.9f);
				//return fixed4(distance,distance,distance,1);

				//return fixed4(node_9706,node_9706,node_9706,1);



				//return fixed4(directSpecular+SampleTexCube(_ReflectionCubeMap,-worldRefl,1),0.6f);
				fixed4 finalCol;
				finalCol.rgb=(gcol.rgb+SampleTexCube(_ReflectionCubeMap,-worldRefl,1)*_ReflectionIntensity*_EnvColor+directSpecular)*(directDiffuse*_WaveShadowIntensity+0.2f);
				finalCol.a=fresnel;

				return fixed4((gcol.rgb*(directDiffuse*_WaveShadowIntensity+0.2f)+SampleTexCube(_ReflectionCubeMap,-worldRefl,0)*_ReflectionIntensity*_EnvColor+directSpecular)*_SceneDarkenColor,fresnel*i.col.a);
				//return fixed4((directDiffuse+_WaveShadowIntensity),1);
			}
			ENDCG
		}

	}

	FallBack "Mobile/VertexLit"
}