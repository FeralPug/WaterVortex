using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CycloneController : MonoBehaviour
{
    [System.Serializable]
    public class CycloneSettings
    {
        [Min (0f)] public float radius;
        [Range (0f, 50f)]public float depth;
        [Min(0f)] public float rim;
    }

    public float cycloneSpeed = 180f;

    [Range (0f, 1f)]
    public float Progress = 0f;
    public CycloneSettings CycloneSettingsTarget;
    CycloneSettings cycloneSettingsCurrent = new CycloneSettings();

    MeshRenderer meshRenderer;

    [HideInInspector]
    public float randomOffset;

    const float DEFAULT_WORLD_SIZE = 10f;
    const float DEFAULT_WORLD_RADIUS = DEFAULT_WORLD_SIZE / 2f;

    MaterialPropertyBlock materialProperty;

    int CYCLONE_SIZE_ID = Shader.PropertyToID("_CycloneSize");
    int CYCLONE_DEPTH_ID = Shader.PropertyToID("_CycloneDepth");
    int CYCLONE_RIM_ID = Shader.PropertyToID("_SwirlRim");
    int CYCLONE_OFFSET_ID = Shader.PropertyToID("_SwirlOffset");
    int CYCLONE_FALLOFF_ID = Shader.PropertyToID("_SwirlFalloff");
    int CYCLONE_SWIRL_AMOUNT_ID = Shader.PropertyToID("_SwirlAmount");

    private void Awake()
    {
        //pick a random offset to use for the swirl so they are all different
        randomOffset = Random.Range(-100, 100);

        OnValidate();
    }

    private void OnValidate()
    {
        UpdatePropertyBlock();
    }

    #region Rendering
    void UpdatePropertyBlock()
    {
        if (meshRenderer == null)
        {
            meshRenderer = GetComponent<MeshRenderer>();
        }

        if (materialProperty == null)
        {
            materialProperty = new MaterialPropertyBlock();
            meshRenderer.GetPropertyBlock(materialProperty);
        }

        UpdateProgress();

        float radius = 0;
        radius += cycloneSettingsCurrent.radius + cycloneSettingsCurrent.rim;
        float scale = radius / DEFAULT_WORLD_RADIUS;
        transform.localScale = new Vector3(scale, scale, scale);

        materialProperty.SetFloat(CYCLONE_SIZE_ID, cycloneSettingsCurrent.radius);
        materialProperty.SetFloat(CYCLONE_DEPTH_ID, cycloneSettingsCurrent.depth);
        materialProperty.SetFloat(CYCLONE_RIM_ID, cycloneSettingsCurrent.rim);
        materialProperty.SetFloat(CYCLONE_OFFSET_ID, randomOffset);

        meshRenderer.SetPropertyBlock(materialProperty);
    }

    void UpdateProgress()
    {
        cycloneSettingsCurrent.depth = Mathf.Lerp(0, CycloneSettingsTarget.depth, Progress);
        cycloneSettingsCurrent.radius = Mathf.Lerp(0, CycloneSettingsTarget.radius, Progress);
        cycloneSettingsCurrent.rim = Mathf.Lerp(0, CycloneSettingsTarget.rim, Progress);
    }

    #endregion

    public CycloneOutput GetCycloneInteraction(Vector3 worldPos)
    {
        //get values from material
        float matFalloff = meshRenderer.sharedMaterial.GetFloat(CYCLONE_FALLOFF_ID);
        float size = cycloneSettingsCurrent.radius;
        float rim = cycloneSettingsCurrent.rim;
        float depth = cycloneSettingsCurrent.depth;

        Vector3 rotatedPos = RotatePos(worldPos, matFalloff, size, rim);

        return GetCycloneOutput(rotatedPos, matFalloff, size, depth);
    }

    Vector3 RotatePos(Vector3 worldPos, float matFalloff, float size, float rim)
    {
        float distanceFromCenter = GetDistanceToCenter(worldPos);

        float falloff = Mathf.Pow(Mathf.SmoothStep(0, 1, (size - distanceFromCenter + rim) / (size + rim)), matFalloff);

        Vector3 localPos = transform.InverseTransformPoint(worldPos);
        localPos = Quaternion.Euler(0f, -cycloneSpeed * Time.deltaTime * Mathf.Clamp01(falloff), 0f) * localPos;
        
        Vector3 rotatedPos = transform.TransformPoint(localPos);

        return rotatedPos;
    }

    //see water and cyclone shader for details
    CycloneOutput GetCycloneOutput(Vector3 rotatedPos, float matFalloff, float size, float depth)
    {
        //get distance
        float dist = GetDistanceToCenter(rotatedPos);

        float falloff = Mathf.Pow(Mathf.SmoothStep(0, 1, (size - dist) / size), matFalloff);

        float disp = falloff * depth;    

        return new CycloneOutput(disp, falloff, rotatedPos);
    }

    float GetDistanceToCenter(Vector3 worldPos)
    {
        Vector2 input = new Vector2(worldPos.x, worldPos.z);
        Vector2 center = new Vector2(transform.position.x, transform.position.z);

        Vector2 delta = input - center;
        return delta.magnitude;
    }
}

public struct CycloneOutput
{
    public float displacement;
    public float heightFalloff;
    public Vector3 rotatedPosition;

    public CycloneOutput(float displacement, float heightFalloff, Vector3 rotatedPosition)
    {
        this.displacement = displacement;
        this.heightFalloff = heightFalloff;
        this.rotatedPosition = rotatedPosition;
    }
}

