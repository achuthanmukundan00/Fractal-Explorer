using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explorer : MonoBehaviour
{
    public Material mat;
    public Vector2 pos;
    public float scale, angle;

    private float scaleMomentum, angleMomentum;
    private Vector2 posMomentum;

    private void UpdateShader()
    {
        posMomentum = Vector2.Lerp(posMomentum, pos, .04f);
        scaleMomentum = Mathf.Lerp(scaleMomentum, scale, .04f);
        angleMomentum = Mathf.Lerp(angleMomentum, angle, .04f);



        float aspect = (float)Screen.width / (float)Screen.height;
        float scaleX = scaleMomentum;
        float scaleY = scaleMomentum;

        if (aspect > 1f)
        {
            scaleY /= aspect;
        }
        else scaleX *= aspect;
        mat.SetVector("_Area", new Vector4(posMomentum.x, posMomentum.y, scaleX, scaleY));
        mat.SetFloat("_Angle", angleMomentum);
    }

    private void HandleInputs()
    {
        // scale keybindings
        if (Input.GetKey(KeyCode.K))
            scale *= .99f;
        if (Input.GetKey(KeyCode.J))
            scale *= 1.01f;

        //angle keybindings
        if (Input.GetKey(KeyCode.Q))
            angle -= .01f;
        if (Input.GetKey(KeyCode.E))
            angle += .01f;

        // makes angle changes not affect the orientation of controls
        Vector2 dir = new Vector2(.01f * scale, 0);
        float s = Mathf.Sin(angle);
        float c = Mathf.Cos(angle);
        dir = new Vector2(dir.x * c, dir.x * s);


        if (Input.GetKey(KeyCode.A))
            pos -= dir;
        if (Input.GetKey(KeyCode.D))
            pos += dir;

        dir = new Vector2(-dir.y, dir.x);

        if (Input.GetKey(KeyCode.W))
            pos += dir;
        if (Input.GetKey(KeyCode.S))
            pos -= dir;
    }
    void FixedUpdate()
    {
        HandleInputs();
        UpdateShader();
    }
}
