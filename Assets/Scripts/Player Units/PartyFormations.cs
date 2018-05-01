﻿using System.Collections.Generic;
using UnityEngine;

public static class PartyFormations {

    public static float formationOffset = 1.5f;

    public static void PartyCircleMove (List<ControllableUnit> selectedUnits, Vector3 formationCenter) {
        // Calculate the average position of the selected units
        Vector3 averagePosition = new Vector3 ();
        foreach (ControllableUnit cu in selectedUnits) {
            averagePosition += cu.transform.position;
        }
        averagePosition /= selectedUnits.Count;

        // Calculate the direction from the average position to the formation center
        Vector2 pos1 = new Vector2 (averagePosition.x, averagePosition.z);
        Vector2 pos2 = new Vector2 (formationCenter.x, formationCenter.z);
        float centerAngle = Vector2.Angle (pos1, pos2);
        float extra = (Vector2.SignedAngle (pos1, pos2));

        float increment = 360f / selectedUnits.Count;

        for (int i = 0; i < selectedUnits.Count; i++) {
            float angle = increment * i;
            Vector3 offset = new Vector3 (formationOffset * Mathf.Cos (angle * Mathf.Deg2Rad), 0f, formationOffset * Mathf.Sin (angle * Mathf.Deg2Rad));
            selectedUnits[i].SetDestination (formationCenter + offset);
        }
    }
}