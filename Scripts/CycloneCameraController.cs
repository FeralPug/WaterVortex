using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteAlways]
public class CycloneCameraController : MonoBehaviour
{
    public Transform focus;
    public Camera CycloneCamera;
    public RenderTexture cycloneBuffer;

    int CYCLONE_BUFFER_ID = Shader.PropertyToID("_CycloneTexture");
    int CYCLONE_CAMERA_POS = Shader.PropertyToID("_CycloneCameraPos");
    int CYCLONE_CAMERA_SIZE = Shader.PropertyToID("_CycloneCameraSize");

    public CameraEvent cameraEvent;
    CommandBuffer cb;

    private void OnEnable()
    {
        Camera.onPreRender += ApplyCommandBuffer;
        Camera.onPostRender += RemoveCommandBuffer;
    }

    private void OnDisable()
    {
        Camera.onPreRender -= ApplyCommandBuffer;
        Camera.onPostRender -= RemoveCommandBuffer;
    }

    void ApplyCommandBuffer(Camera cam)
    {
#if UNITY_EDITOR
        // hack to avoid rendering in the inspector preview window
        if (cam.gameObject.name == "Preview Scene Camera")
            return;
#endif

        if(cam == null || cam != CycloneCamera)
        {
            return;
        }

        CreateCommandBuffer(cam);

        cam.AddCommandBuffer(cameraEvent, cb);
    }

    void RemoveCommandBuffer(Camera cam)
    {
        if(cb != null && cam == CycloneCamera)
        {
            cam.RemoveCommandBuffer(cameraEvent, cb);
        }       
    }

    void CreateCommandBuffer(Camera cam)
    {
        if (cb == null)
        {
            cb = new CommandBuffer();
            cb.name = "Cyclone Camera";
        }
        else
        {
            cb.Clear();
        }

        Vector2 camSize = new Vector2();
        camSize.x = CycloneCamera.orthographicSize * CycloneCamera.aspect;
        camSize.y = CycloneCamera.orthographicSize;        

        cb.SetGlobalVector(CYCLONE_CAMERA_SIZE, camSize);
        cb.SetGlobalVector(CYCLONE_CAMERA_POS, transform.position);
        cb.SetGlobalTexture(CYCLONE_BUFFER_ID, cycloneBuffer);
    }
}
