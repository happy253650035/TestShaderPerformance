Shader "ZJY/Role/SurfaceShaderEye" 
{

	Properties 
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_Cube ("Cubemap", CUBE) = "" {}
		_RefEnvIntensity("RefEnvIntensity",Range(0,5))=1
		_RotationAngle("_RotationAngle(0-360)",Range(0,6.28))=1
		_RefLevel("_RefLevel(0-9)",Range(0,9))=0
    }
    SubShader 
	{
		Tags { "RenderType" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
		sampler2D _BumpMap;
		samplerCUBE _Cube;
		fixed _RefEnvIntensity;
		half _RotationAngle;
		half _RefLevel;

		struct Input 
		{
			half2 uv_MainTex;
			half2 uv_BumpMap;
			half3 worldRefl;  
			INTERNAL_DATA
		};
		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			///c.rgb=GammaToLinearSpace(c.rgb);
			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			float3 worldRefl = WorldReflectionVector (IN, o.Normal * 1);
			float3x3 rotationMatrix = float3x3(cos(_RotationAngle), 0, sin(_RotationAngle),0, 1, 0,-sin(_RotationAngle), 0, cos(_RotationAngle));
			// fixed4 reflcol = texCUBE (_Cube, mul(worldRefl, rotationMatrix) );
			fixed4 reflcol=texCUBElod(_Cube,half4(mul(worldRefl, rotationMatrix) ,_RefLevel));
			 o.Albedo =c.rgb+reflcol.rgb*c.a*_RefEnvIntensity;
			 //o.Albedo=reflcol.rgb*_RefEnvIntensity;
		}
      ENDCG
    } 
    Fallback "Diffuse"
}
