/* by neoliang */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class neoAura : MonoBehaviour {

    [SerializeField]
    Material auraMaterial = null;
    [SerializeField]
    int downSample = 1;

    [SerializeField]
    [Range(0f,10f)]
    float wholeBlurStrength = 1f;
    [SerializeField]
    [Range(1f, 10f)]
    int wholeBlurLoop = 1;

    [SerializeField]
    [Range(0f, 1f)]
    float thresholdAlpha = 0.5f;
    [SerializeField]
    [Range(0.001f, 0.5f)]
    float thresholdWidth = 0.1f;

    [SerializeField]
    Color auraColor = Color.white;

    [SerializeField]
    [Range(0.01f, 10f)]
    float innerBlurStrength = 1f;
    [SerializeField]
    [Range(1f, 10f)]
    int innerBlurLoop = 1;

    [SerializeField]
    [Range(1f, 10f)]
    float enhanceAlpha = 1f;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (auraMaterial == null)
            return;
        RenderTexture temp1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
        RenderTexture temp2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);

        RenderTexture wholeBlurTex = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
        RenderTexture auraEdge = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
        RenderTexture innerMask = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
        RenderTexture innerBlurTex = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);

        //whole blur
        Graphics.Blit(source, temp1, auraMaterial, 0);
        for (int i = 0; i < wholeBlurLoop; i++)
        {
            auraMaterial.SetVector("_OffSets", new Vector4(0, wholeBlurStrength, 0, wholeBlurStrength));
            Graphics.Blit(temp1, temp2, auraMaterial, 0);
            auraMaterial.SetVector("_OffSets", new Vector4(wholeBlurStrength, 0, wholeBlurStrength, 0));
            Graphics.Blit(temp2, temp1, auraMaterial, 0);

        }
        Graphics.Blit(temp1, wholeBlurTex);

        //extract edge
        auraMaterial.SetFloat("thresholdA", thresholdAlpha);
        auraMaterial.SetFloat("widthA", thresholdWidth);
        auraMaterial.SetColor("auraColor", auraColor);
        Graphics.Blit(wholeBlurTex, auraEdge, auraMaterial, 1);
        //extract inner
        Graphics.Blit(wholeBlurTex, innerMask, auraMaterial, 2);

        //inner blur
        auraMaterial.SetTexture("_MaskTex", innerMask);
        Graphics.Blit(auraEdge, temp1, auraMaterial, 3);
        for (int i = 0; i < innerBlurLoop; i++)
        {
            auraMaterial.SetVector("_OffSets", new Vector4(0, innerBlurStrength, 0, innerBlurStrength));
            Graphics.Blit(temp1, temp2, auraMaterial, 3);
            auraMaterial.SetVector("_OffSets", new Vector4(innerBlurStrength, 0, innerBlurStrength, 0));
            Graphics.Blit(temp2, temp1, auraMaterial, 3);
        }
        //Graphics.Blit(innerMask, destination);
        auraMaterial.SetFloat("enhanceA", enhanceAlpha);
        Graphics.Blit(temp1, innerBlurTex, auraMaterial, 4);//enhance
        //overlap
        auraMaterial.SetTexture("_AddTex", auraEdge);
        Graphics.Blit(innerBlurTex, destination, auraMaterial, 5);

        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
        RenderTexture.ReleaseTemporary(wholeBlurTex);
        RenderTexture.ReleaseTemporary(auraEdge);
        RenderTexture.ReleaseTemporary(innerMask);
        RenderTexture.ReleaseTemporary(innerBlurTex);

    }
 }
