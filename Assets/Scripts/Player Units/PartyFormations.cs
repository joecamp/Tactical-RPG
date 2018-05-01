using System.Collections.Generic;
using UnityEngine;

public static class PartyFormations {

    public static float formationOffset = 3f;

    public static void PartyCircleMove (List<ControllableUnit> selectedUnits, Vector3 formationCenter) {
        float increment = 360f / selectedUnits.Count;

        for (int i = 0; i < selectedUnits.Count; i++) {
            float angle = increment * i;
            Vector3 offset = new Vector3 (formationOffset * Mathf.Cos (angle * Mathf.Deg2Rad), 0f, formationOffset * Mathf.Sin (angle * Mathf.Deg2Rad));
            selectedUnits[i].SetDestination (formationCenter + offset);
        }
    }
}