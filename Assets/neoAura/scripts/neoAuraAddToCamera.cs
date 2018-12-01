/* by neoliang */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class neoAuraAddToCamera : MonoBehaviour {

    [SerializeField]
    Material auraMaterial = null;
    [SerializeField]
    Texture auraTexture = null;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (auraMaterial)
        {
            auraMaterial.SetTexture("_AddTex", auraTexture);
            Graphics.Blit(source, destination, auraMaterial, 5);

        }
    }
}
