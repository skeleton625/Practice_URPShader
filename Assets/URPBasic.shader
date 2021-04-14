Shader "URPTraining/URPBasic"
{
	// Material을 통해 외부에서 조절할 수 있는 변수(속성)들 
	Properties
	{
		// 컬러 팔레트 변수
		_SampleColor("Sample Color", Color) = (1, 1, 1, 1)
		// 범위 값으로 정의된 변수
		_SampleIntensity("Sample Range", Range(0, 1)) = 0.5
		// x, y, z, w, 4개의 값을 가진 벡터 변수
		_SampleVector("Sample Vector", Vector) = (0, 0, 0, 0)
		// 실수형 변수 (int, float 자료형 타입 사용 가능)
		_SampleFloat("Sample Float", Float) = 0
		// Texture Sampler 타입의 변수
		_SampleTexture01("Sample Texture 01", 2D) = "white"{}
	// Texture Sampler 타입의 변수
	_SampleTexture02("Sample Texture 02", 2D) = "white"{}
	}

		// 메시를 랜더링 할 때, 랜더링 과정을 정의하는 부분
		SubShader
	{
		// SubShader의 타입을 결정
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Opeque"
			"Queue" = "Geometry"
		}

		// SubShader에서 사용할 랜더 패스를 정의
		// 렌더 패스 : 메시를 랜더링 할 때, 색, 효과들을 적용하는 각각의 과정
		Pass
		{
			Name "Universal Forward"
			Tags { "LightMode" = "UniversalForward" }

			// HSLS 시작
			HLSLPROGRAM

			#pragma prefer_hlslcc gles			// 안드로이드에서 쉐이더 컴파일, 크로스 컴파일을 위해 SRP에서 HLSLcc를 사용
			#pragma exclude_renderers d3d11_9x	// Direct3D 9 사용을 제외
			#pragma vertex vert					// Vertex Shading 과정을 'vert' 함수로 정의
			#pragma fragment frag				// Fragment Shading 과정을 'frag' 함수로 정의

			// URP 패키지에 존재하는 Lighting hlsl 파일 참조
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			// Properties 에서 정의한 변수들을 SubShader에서 사용하기 위해 정의
			half4 _SampleColor;
			float _SampleFloat;
			float _SampleIntensity;
			float4 _SampleVector;
			float4 _SampleTexture01_ST;			// _SampleTexture의 Tile, Offset 값 -> "[텍스처 변수명]_ST"
			float4 _SampleTexture02_ST;
			Texture2D _SampleTexture01;
			Texture2D _SampleTexture02;
			SamplerState sampler_SampleTexture01; // _SampleTexture01 Texture2D의 보간기

			// vertex buffer에서 읽어올 정보 구조체 정의
			struct VertexInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			/*
			* 보간기(정보 전달 매체)를 통해 Vertex Shading에서 Pixel Shading(Fragment Shading)로
			* 전달되는 정보 구조체
			*/
			struct VertexOutput
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			// Rendering Pipeline의 Vertex Shading 과정 함수 -> 메시의 점을 찍는 과정
			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				// 월드 좌표계를 모니터 좌표계로 위치 변경
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.uv;
				// _SampleTexture_ST의 xy는 Tile Size, zw는 Offset 값을 의미
				// o.uv = v.uv.xy * _SampleTexture01_ST.xy + _SampleTexture01_ST.zw;

				return o;
			}

			// Vertex Shader, Fragment Shader 중간에 월드 좌표계(3D)에서 모니터 좌표계(2D)로 변경하는 과정(Rasterization)이 존재

			// Rendering Pipeline의 Pixel Shading(Fragment Shading) 과정 함수 -> 모니터 Pixel을 찍는 과정
			half4 frag(VertexOutput i) : SV_Target
			{
				float2 uv01 = i.uv.xy * _SampleTexture01_ST.xy + _SampleTexture01_ST.zw;
				float2 uv02 = i.uv.xy * _SampleTexture02_ST.xy + _SampleTexture02_ST.zw;

				// 샘플링을 통해 SampleTexture Tile, offset 조정
				// half4 color01 = tex2D(_SampleTexture01, uv01) -> 한 번 정의할 때마다 새 보간기 사용 ( 보간기 개수는 기기에 따라 제한되어 있음)
				half4 color01 = _SampleTexture01.Sample(sampler_SampleTexture01, uv01) * _SampleColor * _SampleIntensity;
				half4 color02 = _SampleTexture02.Sample(sampler_SampleTexture01, uv02) * _SampleColor * _SampleIntensity;

				half4 color = color01 * color02;
				return color;
			}

			// HSLS 끝
			ENDHLSL
		}
	}
}