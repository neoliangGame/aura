using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class neoFPS : MonoBehaviour {
    float duraction = 1f;
    int fpsCount = 0;
    float timeCount = 0f;
    public Text text;

    void Update()
    {
        fpsCount++;
        timeCount += Time.deltaTime;
        if (timeCount >= duraction)
        {
            float fps = fpsCount / timeCount;
            text.text = string.Format("{0:F2}",fps) + " FPS";
            fpsCount = 0;
            timeCount = 0f;
        }
    }
}
