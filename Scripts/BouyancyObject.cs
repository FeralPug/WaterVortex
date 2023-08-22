using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BouyancyObject : MonoBehaviour
{
    public LayerMask cycloneLayer;

    public float submerganceRange = .5f;

    CycloneController currentCycloneController;

    private void Update()
    {
        CalculatePosition();
    }

    void CalculatePosition()
    {
        CycloneOutput cycloneOutput = GetCycloneOutput();

        float waveHeight = Feral_WaterCyclone.WaterPlaneController.Instance.GetWaterHeight(cycloneOutput.rotatedPosition);      

        Vector3 position = transform.position;

        position.x = cycloneOutput.rotatedPosition.x;
        position.z = cycloneOutput.rotatedPosition.z;

        position.y = cycloneOutput.displacement * -1 +
            waveHeight * (1 - Mathf.Clamp01(cycloneOutput.heightFalloff)) * -1;

        transform.position = position;
    }

    CycloneOutput GetCycloneOutput()
    {
        CycloneOutput co;

        if (!FindCyclone(out currentCycloneController))
        {
            co = new CycloneOutput();
            co.rotatedPosition = transform.position;
            return co;
        }

        co = currentCycloneController.GetCycloneInteraction(transform.position);

        return co;
    }

    bool FindCyclone(out CycloneController cyclone)
    {
        cyclone = null;
        if(Physics.Raycast(transform.position, Vector3.down, out RaycastHit hit, 500f, cycloneLayer.value))
        {
            cyclone = hit.collider.gameObject.GetComponent<CycloneController>();
            if (cyclone)
            {
                return true;
            }
        }

        return false;
    }
}
