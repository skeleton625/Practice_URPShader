Shader "URPTraining/URPTransparent"
{
    Properties
    {
        _SampleColor("Sample Color", Color) = (1, 1, 1, 1)
        _SampleAlpha("Sample Alpha", Range(0, 1)) = 1
        _SampleIntensity("Sample Intensity", Range(0, 1)) = 0.5
        _SampleTexture01("Sample Texture 01", 2D) = "white" {}

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 0
        _Factor("Offset Factor", int) = 0
        _Unlit("Offset Unlit", int) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Blend [_SrcBlend][_DstBlend]   // Src -> 계산된 컬러, Dst -> 화면에 표시된 컬러
            Cull [_Cull]                   // Rendering 방향
            Zwrite [_ZWrite]               // Z Depth 유무
            ZTest [_ZTest]                 // 오브젝트의 통과 유무
            Offset [_Factor],[_Unlit]     // Depth Offset 값 -> 여기선 Properties Vector 사용 불가

            Name "Universal Forward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            half4 _SampleColor;
            float _SampleAlpha;
            float _SampleIntensity;
            float4 _SampleTexture01_ST;
            Texture2D _SampleTexture01;
            SamplerState sampler_SampleTexture01;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv.xy * _SampleTexture01_ST.xy + _SampleTexture01_ST.zw;

                return o;
            }

            half4 frag(VertexOutput i) : SV_Target
            {
                half4 color01 = _SampleTexture01.Sample(sampler_SampleTexture01, i.uv);
                color01.rgb *= _SampleColor * _SampleIntensity;
                color01.a *= _SampleAlpha;
                return color01;
            }

            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
