using UnityEngine;
using UnityEngine.InputSystem;

public class FireController : MonoBehaviour
{
    
    [SerializeField] private Renderer objectRenderer;
    [SerializeField] private Renderer flameRenderer;
    
    [Header("Object")]
    [SerializeField] private bool isBurning = true;
    [SerializeField] private float emissionStrength = 170f;
    [SerializeField] private float fireSpeed = 1f;
    [SerializeField] private float fireThreshold = 0.027f;
    
    [Header("Billboard")]
    [SerializeField] private float brightness = 22f;
    [SerializeField] private float scrollSpeed = 1f;
    [SerializeField] private float fadeStart = 0.622f;
    [SerializeField] private float fadeEnd = 0.813f;
    [SerializeField] private float edgeFadeStart = 0f;
    [SerializeField] private float edgeFadeEnd = 0.403f;
    [SerializeField] private float edgeNoiseStrength = 0.942f;
    [SerializeField] private float alphaNoiseStrength = 0.294f;
    [SerializeField] private float billboardScale = 6.16f;
   

    public void SetBurning(bool burning)
    {
        float value = burning ? 1f : 0f;

        // objectRenderer.material.SetFloat("_FlamesEnabled", value);
        // flameRenderer.material.SetFloat("_FlamesEnabled", value);
    }
    
    private void Start()
    {
        ApplySettings();
        // objectRenderer.material.SetFloat("_FlamesEnabled", 0);
        // flameRenderer.material.SetFloat("_FlamesEnabled", 0);
        // Debug.Log("fire should be off");
    }
    
    void Update()
    {
        if (Keyboard.current.fKey.wasPressedThisFrame)
            isBurning = true;
        
        if (Keyboard.current.gKey.wasPressedThisFrame)
            isBurning = false;
        
        ApplySettings(); //Enable this here if want to see changes during gameplay. Comment out otherwise.
        
    }
    private void ApplySettings()
    {
        // Sphere
        float enabled = isBurning ? 1f : 0f;
        objectRenderer.material.SetFloat("_FlamesEnabled", enabled);
        objectRenderer.material.SetFloat("_FireSpeed", fireSpeed);
        objectRenderer.material.SetFloat("_FireThreshold", fireThreshold);
        objectRenderer.material.SetFloat("_EmissionStrength", emissionStrength);
        
        // Billboard
        flameRenderer.material.SetFloat("_FlamesEnabled", enabled);
        flameRenderer.material.SetFloat("_Brightness", brightness);
        flameRenderer.material.SetFloat("_FireScrollSpeed", scrollSpeed);
        
        flameRenderer.material.SetFloat("_FadeStart", fadeStart);
        flameRenderer.material.SetFloat("_FadeEnd", fadeEnd);
        flameRenderer.material.SetFloat("_EdgeFadeStart", edgeFadeStart);
        flameRenderer.material.SetFloat("_EdgeFadeEnd", edgeFadeEnd);
        flameRenderer.material.SetFloat("_EdgeNoiseStrength", edgeNoiseStrength);
        flameRenderer.material.SetFloat("_AlphaNoiseStrength", alphaNoiseStrength);
        flameRenderer.material.SetFloat("_BillboardScale", billboardScale);
    }
}
