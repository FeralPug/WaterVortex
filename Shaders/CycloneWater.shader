Shader "Feral_Pug/CycloneWater"
{
    Properties
    {
        _WaterColor("Water Color", Color) = (1,1,1,1)
        _SwirlColor("Swirl Color", Color) = (1,1,1,1)

        _HeightMap("Height Map", 2D) = "gray" {}

        _Tess("Tessellation", float) = 1

        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0

        _WaveHeight("Wave Height", float) = 1.0
        _WaveSpeed("Wave Speed", Range(0, .1)) = 0.5
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            //ZWrite Off
            LOD 200

            CGPROGRAM
            #include "Includes/CycloneInclude.cginc"

            // Physically based Standard lighting model, and enable shadows on all light types
            #pragma surface surf Standard vertex:vert fullforwardshadows tessellate:tessFixed// alpha:premul

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 4.6

            sampler2D  _HeightMap;
            float4 _HeightMap_TexelSize;
            float4 _HeightMap_ST;

            sampler2D _CycloneTexture;
            float4 _CycloneCameraPos;
            float2 _CycloneCameraSize;

            struct Input
            {
                float2 uv_HeightMap;
                float3 worldPos;
            };

            half _Glossiness;
            half _Metallic;
            fixed4 _WaterColor, _SwirlColor;

            float _WaveHeight;
            float _Tess;

            float _WaveSpeed;

            float4 tessFixed() {
                return _Tess;
            }

            float RemapFloat(float In, float2 InMinMax, float2 OutMinMax)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            float2 WorldPosToCameraUV(float2 worldPos) {
                float2 uv;

                float4 camExtents;
                camExtents.x = _CycloneCameraPos.x - _CycloneCameraSize.x;
                camExtents.y = _CycloneCameraPos.x + _CycloneCameraSize.x;
                camExtents.z = _CycloneCameraPos.z - _CycloneCameraSize.y;
                camExtents.w = _CycloneCameraPos.z + _CycloneCameraSize.y;

                uv.x = RemapFloat(worldPos.x, camExtents.xy, float2(0, 1));
                uv.y = RemapFloat(worldPos.y, camExtents.zw, float2(0, 1));

                return uv;
            }

            //https://forum.unity.com/threads/solved-recalculate-normals-displacement.753779/
            //https://forum.unity.com/threads/calculate-vertex-normals-in-shader-from-heightmap.169871/
            
            float3 filterNormal(float2 worldPos, float2 texelSize, float terrainSize)
            {
                float4 h = 0;
                float2 offsetWorldPos;
                float2 cycloneUV;
                float noise;
                float4 cyclone;

                offsetWorldPos = worldPos + terrainSize * texelSize * float2(0, -1);
                cycloneUV = WorldPosToCameraUV(offsetWorldPos);
                cyclone = 0;
                if (cycloneUV.x >= 0 && cycloneUV.x <= 1.0 && cycloneUV.y >= 0 && cycloneUV.y <= 1.0) {
                    cyclone = tex2Dlod(_CycloneTexture, float4(cycloneUV, 0, 0));
                    cyclone.g = RemapFloat(cyclone.g, float2(0, 1), float2(0, 50));
                }
                noise = tex2Dlod(_HeightMap, float4(offsetWorldPos * _HeightMap_ST.xy + _Time.y * _WaveSpeed, 0, 0)).r * 2 - 1;
                noise *= tex2Dlod(_HeightMap, float4(offsetWorldPos * _HeightMap_ST.xy - _Time.y * _WaveSpeed + _HeightMap_ST.zw, 0, 0)).r * 2 - 1;
                h[0] -= cyclone.g + noise * _WaveHeight * (1 - saturate(cyclone.b));

                
                offsetWorldPos = worldPos + terrainSize * texelSize * float2(-1, 0);
                cycloneUV = WorldPosToCameraUV(offsetWorldPos);
                cyclone = 0;
                if (cycloneUV.x >= 0 && cycloneUV.x <= 1.0 && cycloneUV.y >= 0 && cycloneUV.y <= 1.0) {
                    cyclone = tex2Dlod(_CycloneTexture, float4(cycloneUV, 0, 0));
                    cyclone.g = RemapFloat(cyclone.g, float2(0, 1), float2(0, 50));
                }
                noise = tex2Dlod(_HeightMap, float4(offsetWorldPos * _HeightMap_ST.xy + _Time.y * _WaveSpeed, 0, 0)).r * 2 - 1;
                noise *= tex2Dlod(_HeightMap, float4(offsetWorldPos * _HeightMap_ST.xy - _Time.y * _WaveSpeed + _HeightMap_ST.zw, 0, 0)).r * 2 - 1;
                h[1] -= cyclone.g + noise * _WaveHeight * (1 - saturate(cyclone.b));


                offsetWorldPos = worldPos + terrainSize * texelSize * float2(1, 0);
                cycloneUV = WorldPosToCameraUV(offsetWorldPos);
                cyclone = 0;
                if (cycloneUV.x >= 0 && cycloneUV.x <= 1.0 && cycloneUV.y >= 0 && cycloneUV.y <= 1.0) {
                    cyclone = tex2Dlod(_CycloneTexture, float4(cycloneUV, 0, 0));
                    cyclone.g = RemapFloat(cyclone.g, float2(0, 1), float2(0, 50));
                }
                noise = tex2Dlod(_HeightMap, float4(offsetWorldPos * _HeightMap_ST.xy + _Time.y * _WaveSpeed, 0, 0)).r * 2 - 1;
                noise *= tex2Dlod(_HeightMap, float4(offsetWorldPos * _HeightMap_ST.xy - _Time.y * _WaveSpeed + _HeightMap_ST.zw, 0, 0)).r * 2 - 1;
                h[2] -= cyclone.g + noise * _WaveHeight * (1 - saturate(cyclone.b));


                offsetWorldPos = worldPos + terrainSize * texelSize * float2(0, 1);
                cycloneUV = WorldPosToCameraUV(offsetWorldPos);
                cyclone = 0;
                if (cycloneUV.x >= 0 && cycloneUV.x <= 1.0 && cycloneUV.y >= 0 && cycloneUV.y <= 1.0) {
                    cyclone = tex2Dlod(_CycloneTexture, float4(cycloneUV, 0, 0));
                    cyclone.g = RemapFloat(cyclone.g, float2(0, 1), float2(0, 50));
                }
                noise = tex2Dlod(_HeightMap, float4(offsetWorldPos * _HeightMap_ST.xy + _Time.y * _WaveSpeed, 0, 0)).r * 2 - 1;
                noise *= tex2Dlod(_HeightMap, float4(offsetWorldPos * _HeightMap_ST.xy - _Time.y * _WaveSpeed + _HeightMap_ST.zw, 0, 0)).r * 2 - 1;
                h[3] -= cyclone.g + noise * _WaveHeight * (1 - saturate(cyclone.b));             
            
                float3 n;
                //this Z was backwards, unity's plane might have the Z the other direction which is why that is
                //n.z = -(h[0] - h[3]);
                n.z = (h[0] - h[3]);
                n.x = (h[1] - h[2]);
                n.y = 2 * texelSize * terrainSize; // pixel space -> uv space -> world space

                return normalize(n);
            }
            

            void vert(inout appdata_full v) {

                //get worldPos for noise
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float2 cycloneUV = WorldPosToCameraUV(worldPos.xz);
                float4 cyclone = 0;
                
                if (cycloneUV.x >= 0 && cycloneUV.x <= 1.0 && cycloneUV.y >= 0 && cycloneUV.y <= 1.0) {
                    cyclone = tex2Dlod(_CycloneTexture, float4(cycloneUV, 0, 0));
                    cyclone.g = RemapFloat(cyclone.g, float2(0, 1), float2(0, 50));

                    //values in texture are
                    //r = swirl
                    //g = displancement
                    //b = heightFalloff
                }

                float noise = tex2Dlod(_HeightMap, float4(worldPos.xz * _HeightMap_ST.xy + _Time.y * _WaveSpeed, 0, 0)).r * 2 - 1;
                noise *= tex2Dlod(_HeightMap, float4(worldPos.xz * _HeightMap_ST.xy - _Time.y * _WaveSpeed + _HeightMap_ST.zw, 0, 0)).r * 2 - 1;

                float disp = cyclone.g +noise * _WaveHeight * (1 - saturate(cyclone.b));

                worldPos.y -= disp;
                v.vertex = mul(unity_WorldToObject, float4(worldPos, 1));

                v.normal = filterNormal(worldPos.xz, _HeightMap_TexelSize.xy, 100);

                float3 tan = normalize(cross(v.normal, float3(0, 0, 1)));
                v.tangent.xyz = tan;

            }

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)



            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                //calculate uv for cycloneTexture
                float2 cycloneUV = WorldPosToCameraUV(IN.worldPos.xz);

                float4 cyclone = tex2D(_CycloneTexture, cycloneUV);
                if (!(cycloneUV.x >= 0 && cycloneUV.x <= 1.0 && cycloneUV.y >= 0 && cycloneUV.y <= 1.0)) {
                    cyclone = 0;
                }
                //lerp to final color based off of swirl value
                o.Albedo = lerp(_WaterColor.rgb, _SwirlColor.rgb, cyclone.r);

                //surface shader stuff
                // Metallic and smoothness come from slider variables
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Alpha = 1.0;
            }
            ENDCG
        }
            FallBack "Diffuse"
}
