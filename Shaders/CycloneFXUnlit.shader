Shader "Feral_Pug/CycloneFXUnlit"
{
    Properties
    {
        _SwirlTex("Swirl Tex (RGB)", 2D) = "white" {}
        _CycloneDepth("Cyclone Depth", float) = 1
        _SwirlSpeed("Swirl Speed", float) = .1
        _SwirlAmount("Swirl Amount", float) = .2
        _SwirlScale("Swirl Scale", Range(0, .5)) = .03
        _SwirlSmoothing("Swirl Smoothing", Range(0, .5)) = .1
        _CycloneSize("Cyclone Size", float) = 1
        _SwirlFalloff("Swirl Falloff", float) = .5
        _SwirlRim("Swirl Rim", float) = 1
        [HideInInspector]_SwirlOffset("Swirl Offset", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        //ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Includes/CycloneInclude.cginc"

            #pragma target 4.6

            sampler2D _SwirlTex;
            float _SwirlOffset, _SwirlScale, _CycloneDepth, _SwirlSpeed, _SwirlAmount, _SwirlSmoothing, _CycloneSize, _SwirlFalloff, _SwirlRim;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float3 worldOrigin : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float RemapFloat(float In, float2 InMinMax, float2 OutMinMax)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldOrigin = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //get polar coords
                float2 polarUV;
                PolarCoord(i.worldPos.xz, i.worldOrigin.xz, 1, 1, polarUV);

                //cache distance
                float distance = polarUV.x;
                float angle = polarUV.y;

                float heightFalloff = pow(smoothstep(0, 1, (_CycloneSize - distance) / _CycloneSize), _SwirlFalloff);
                float disp = heightFalloff * _CycloneDepth;

                //falloff for the effect
                //strength controlls how wide the effect area is and falloff controlls the fade
                float swirlFalloff = pow(smoothstep(0, 1, (_CycloneSize - distance + _SwirlRim) / _CycloneSize), _SwirlFalloff);

                //amount controlls how coiled the effect is
                //the 1.0 - x is to have if more spiraled in the center of the effect
                //polarUV.y += (1.0 - distance) * _SwirlAmount;
                //polarUV.y += (1.0 - saturate(heightFalloff)) * _SwirlAmount;
                polarUV.y += saturate(heightFalloff) * _SwirlAmount;
                //pulls the swirl in, offset so that they are all different
                polarUV.x += _SwirlOffset;
                polarUV.x += _Time.y * _SwirlSpeed;

                //get the swirl texture with the modified uvs
                float swirl = tex2D(_SwirlTex, polarUV * float2(_SwirlScale, 1)).r;

                //final swirl is smoothed with a smoothstep and multiplied by the falloff
                swirl = smoothstep(.5 - _SwirlSmoothing, .5 + _SwirlSmoothing, swirl);

                float4 c = 0;

                //lerp to final color based off of swirl value
                c.r = lerp(0, 1, saturate(swirl * swirlFalloff));
                c.g = RemapFloat(disp, float2(0, 50), float2(0, 1));
                c.b = heightFalloff;

                c.a = swirlFalloff;

                return c;
            }
            ENDCG
        }
    }
}
