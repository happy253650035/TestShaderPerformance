Shader "ZJY/Scene/CustomSurfacePBRShader" 
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "white" {}
		_Mask01Map("(R)Metallic (G)Smoothness (B)Bloom ", 2D) = "white" {}
		//_Glossiness ("Smoothness", Range(0,1)) = 0.5
		//_Metallic ("Metallic", Range(0,1)) = 0.0
		_MetallicRemappingLow("MetallicRemappingLow",Range(0.01,1))=0.01
		_MetallicRemappingHigh("MetallicRemappingHigh",Range(0.02,1))=1
		[HideInInspector]_MetallicRemappingLevelLow("MetallicRemappingLevelLow",Range(0,1))=0
        [HideInInspector]_MetallicRemappingLevelHigh("MetallicRemappingLevelHigh",Range(0,1))=1
		_SmoothnessRemappingLow("SmoothnessRemappingLow",Range(0.01,1))=0.01
		_SmoothnessRemappingHigh("SmoothnessRemappingHigh",Range(0.02,1))=1
		[HideInInspector]_SmoothnessRemappingLevelLow("SmoothnessRemappingLevelLow",Range(0,1))=0
        [HideInInspector]_SmoothnessRemappingLevelHigh("SmoothnessRemappingLevelHigh",Range(0,1))=1
		[KeywordEnum(None,Metallic, Smoothness)] Debug ("Debug Mode", Float) = 0

	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		#pragma multi_compile DEBUG_NONE DEBUG_METALLIC DEBUG_SMOOTHNESS
		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_Mask01Map;

		};

		sampler2D  _BumpMap;
		sampler2D  _Mask01Map;	
		fixed4 _Color;
		uniform fixed3 _SceneDarkenColor;
		fixed _SmoothnessRemappingLow;
		fixed _SmoothnessRemappingHigh;
		fixed _SmoothnessRemappingLevelLow;
        fixed _SmoothnessRemappingLevelHigh;

		fixed _MetallicRemappingLow;
		fixed _MetallicRemappingHigh;
            
		fixed _MetallicRemappingLevelLow;
        fixed _MetallicRemappingLevelHigh;



		//fixed _Metallic;
		//fixed _Glossiness;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		//UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		//UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			half f_smoothness=(_SmoothnessRemappingLevelHigh-_SmoothnessRemappingLevelLow)/(_SmoothnessRemappingHigh-_SmoothnessRemappingLow);
			half f_metallic=(_MetallicRemappingLevelHigh-_MetallicRemappingLevelLow)/(_MetallicRemappingHigh-_MetallicRemappingLow);
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			
			fixed3 bump = tex2D (_BumpMap, IN.uv_BumpMap);
			fixed4 mask01 = tex2D (_Mask01Map, IN.uv_Mask01Map);

			c.rgb=GammaToLinearSpace(c.rgb);
			//mask01.rgb=GammaToLinearSpace(mask01.rgb);
			fixed remappingMetallic=(mask01.r-_MetallicRemappingLow)*f_metallic;
			remappingMetallic=clamp(remappingMetallic,0,1);
			fixed remappingSmoothness=(mask01.g-_SmoothnessRemappingLow)*f_smoothness;
			remappingSmoothness=clamp(remappingSmoothness,0,1);
			o.Albedo = c.rgb*_SceneDarkenColor;
			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			o.Metallic = remappingMetallic;
			o.Smoothness = remappingSmoothness;
			
			



		}

		ENDCG
	}
	FallBack "Diffuse"
}
