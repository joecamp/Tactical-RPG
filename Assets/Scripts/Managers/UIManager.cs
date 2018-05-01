using UnityEngine;

public class UIManager : MonoBehaviour {

    [SerializeField] GameObject gameMenu;
    [SerializeField] GameObject pauseIndicator;

    public void ToggleGameMenu () {
        gameMenu.SetActive (!gameMenu.activeSelf);
    }


    public void TogglePauseIndicator () {
        pauseIndicator.SetActive (!pauseIndicator.activeSelf);
    }
}
