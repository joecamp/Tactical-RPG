using UnityEngine;

public class CameraMovement : MonoBehaviour {

    public bool followTargets = false;

    public Transform[] targets;                   // All the targets the camera needs to encompass

    public float screenEdgeBuffer = 4f;           // Space between the top/bottom most target and the screen edge
    public float minSize = 6.5f;                  // The smallest orthographic size the camera can be
    public float zoomDampTime = 0.2f;
    public float inputMovementSpeed = 0.1f;
    public float inputSmoothness = 0.85f;

    new private Camera camera;                    // Used for referencing the camera
    private float zoomSpeed;                      // Reference speed for the smooth damping of the orthographic size
    private Vector3 goalPosition;                 // The position the camera is moving towards


    protected void Awake () {
        camera = GetComponentInChildren<Camera> ();
        goalPosition = transform.position;
    }


    protected void Update () {
        if (Input.GetKeyDown (KeyCode.F)) {
            ToggleCameraMode ();
        }
        if (Input.GetKeyUp (KeyCode.F)) {
            ToggleCameraMode ();
        }
    }


    protected void LateUpdate () {
        if (followTargets) {
            FollowTargetsMove ();
            //FollowTargetsZoom ();
        }
        else {
            InputMove ();
            InputZoom ();
            ScreenEdgeMove ();
        }
    }


    public void ToggleCameraMode () {
        followTargets = !followTargets;
        goalPosition = transform.position;
    }


    protected void InputMove () {
        if (Input.GetKey (KeyCode.W))
            goalPosition += transform.up * inputMovementSpeed;
        if (Input.GetKey (KeyCode.S))
            goalPosition -= transform.up * inputMovementSpeed;
        if (Input.GetKey (KeyCode.A))
            goalPosition -= transform.right * inputMovementSpeed;
        if (Input.GetKey (KeyCode.D))
            goalPosition += transform.right * inputMovementSpeed;

        transform.position = Vector3.Lerp (transform.position, goalPosition, (1.0f - inputSmoothness));
    }


    protected void InputZoom () {

    }


    protected void ScreenEdgeMove () {
        Vector3 pos = Input.mousePosition;

        if (pos.x == 0.0) Debug.Log ("Move Left");
        if (pos.x == Camera.main.pixelWidth - 1) Debug.Log ("Move Right");
        if (pos.y == Camera.main.pixelHeight - 1) Debug.Log ("Move Up");
        if (pos.y == 0.0) Debug.Log ("Move Down");
    }


    protected void FollowTargetsMove () {
        FindAveragePosition ();
        transform.position = goalPosition;
    }


    protected void FollowTargetsZoom () {
        float requiredSize = FindRequiredSize ();
        camera.orthographicSize = Mathf.SmoothDamp (camera.orthographicSize, requiredSize, ref zoomSpeed, zoomDampTime);
    }


    protected void FindAveragePosition () {
        Vector3 averagePos = new Vector3 ();
        int numTargets = 0;

        // Go through all the targets and add their positions together
        for (int i = 0; i < targets.Length; i++) {
            // If the target isn't active, go on to the next one
            if (!targets[i].gameObject.activeSelf)
                continue;

            // Add to the average and increment the number of targets in the average
            averagePos += targets[i].position;
            numTargets++;
        }

        // If there are targets divide the sum of the positions by the number of them to find the average
        if (numTargets > 0)
            averagePos /= numTargets;

        // Keep the same y value
        averagePos.y = transform.position.y;
        // The goal position is the average position
        goalPosition = averagePos;
    }


    protected float FindRequiredSize () {
        // Find the position the camera rig is moving towards in its local space
        Vector3 desiredLocalPos = transform.InverseTransformPoint (goalPosition);
        // Start the camera's size calculation at zero
        float size = 0f;

        // Go through all the targets...
        for (int i = 0; i < targets.Length; i++) {
            // ...and if they aren't active continue on to the next target
            if (!targets[i].gameObject.activeSelf)
                continue;

            // Otherwise, find the position of the target in the camera's local space
            Vector3 targetLocalPos = transform.InverseTransformPoint (targets[i].position);
            // Find the position of the target from the desired position of the camera's local space
            Vector3 desiredPosToTarget = targetLocalPos - desiredLocalPos;
            // Choose the largest out of the current size and the distance of the tank 'up' or 'down' from the camera
            size = Mathf.Max (size, Mathf.Abs (desiredPosToTarget.y));
            // Choose the largest out of the current size and the calculated size based on the tank being to the left or right of the camera
            size = Mathf.Max (size, Mathf.Abs (desiredPosToTarget.x) / camera.aspect);
        }

        // Add the edge buffer to the size
        size += screenEdgeBuffer;
        // Make sure the camera's size isn't below the minimum
        size = Mathf.Max (size, minSize);

        return size;
    }
}