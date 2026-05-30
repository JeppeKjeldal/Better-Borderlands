using UnityEngine;
using UnityEngine.InputSystem;

public class FireController : MonoBehaviour
{
    
    [SerializeField] private Renderer objectRenderer;
    [SerializeField] private Renderer flameRenderer;

    public void SetBurning(bool burning)
    {
        float value = burning ? 1f : 0f;

        // objectRenderer.material.SetFloat("_FlamesEnabled", value);
        // flameRenderer.material.SetFloat("_FlamesEnabled", value);
    }
    
    void Start()
    {
        //SetBurning(true);
        SetBurning(false);
        objectRenderer.material.SetFloat("_FlamesEnabled", 0);
        flameRenderer.material.SetFloat("_FlamesEnabled", 0);
        Debug.Log("fire should be off");
    }

    
    void Update()
    {
        if (Keyboard.current.fKey.wasPressedThisFrame)
        {
            // SetBurning(true);
            objectRenderer.material.SetFloat("_FlamesEnabled", 1);
            flameRenderer.material.SetFloat("_FlamesEnabled", 1);
            Debug.Log("Button pressed, fire should start");
        }
        if (Keyboard.current.gKey.wasPressedThisFrame)
        {
            // SetBurning(true);
            objectRenderer.material.SetFloat("_FlamesEnabled", 0);
            flameRenderer.material.SetFloat("_FlamesEnabled", 0);
            Debug.Log("Button pressed, fire should start");
        }
        
    }
}
