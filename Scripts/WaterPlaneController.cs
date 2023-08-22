using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Feral_WaterCyclone
{
    public class WaterPlaneController : MonoBehaviour
    {
        public static WaterPlaneController Instance;

        public CycloneCameraController cycloneCamera;
        public Material waterPlaneMaterial;
        public Texture2D waterHeightMap;

        string WAVE_HEIGHT_MAP_ID = "_HeightMap";
        string WAVE_HEIGHT_ID = "_WaveHeight";
        string WAVE_SPEED_ID = "_WaveSpeed";

        float waveSpeed;
        float waterHeight;
        Vector2 waveHeightMapScale;
        Vector2 waveHeightMapOffset;


        public float WaveHeight
        {
            get
            {
                return waterPlaneMaterial.GetFloat(WAVE_HEIGHT_ID);
            }
        }

        private void Awake()
        {
            if(Instance == null)
            {
                Instance = this;
            }

            if (waterHeightMap)
            {
                waveHeightMapScale = waterPlaneMaterial.GetTextureScale(WAVE_HEIGHT_MAP_ID);
                waveHeightMapOffset = waterPlaneMaterial.GetTextureOffset(WAVE_HEIGHT_MAP_ID);
                waveSpeed = waterPlaneMaterial.GetFloat(WAVE_SPEED_ID);
                waterHeight = waterPlaneMaterial.GetFloat(WAVE_HEIGHT_ID);
            }
        }

        public float GetWaterHeight(Vector3 position)
        {
            Vector2 uv = new Vector2();

            uv.x = position.x * waveHeightMapScale.x + Time.timeSinceLevelLoad * waveSpeed;
            uv.y = position.z * waveHeightMapScale.y + Time.timeSinceLevelLoad * waveSpeed;
            float noise = waterHeightMap.GetPixelBilinear(uv.x, uv.y).r * 2f - 1f;

            uv.x = position.x * waveHeightMapScale.x - Time.timeSinceLevelLoad * waveSpeed + waveHeightMapOffset.x;
            uv.y = position.z * waveHeightMapScale.y - Time.timeSinceLevelLoad * waveSpeed + waveHeightMapOffset.y;
            noise *= waterHeightMap.GetPixelBilinear(uv.x, uv.y).r * 2f - 1f;

            return noise * waterHeight;
        }

    }


}


