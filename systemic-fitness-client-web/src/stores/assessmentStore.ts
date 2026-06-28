import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import { PhaseAInput, PhaseBInput, PhaseCInput, AssessmentV2Draft } from "@/types/assessment";

interface AssessmentState {
  draft: AssessmentV2Draft;
  setPhaseA: (data: Partial<PhaseAInput>) => void;
  setPhaseB: (data: Partial<PhaseBInput>) => void;
  setPhaseC: (data: Partial<PhaseCInput>) => void;
  reset: () => void;
}

const defaultPhaseA: PhaseAInput = {
  physicalStatusLevel: "level_4_5_perf",
  hasMedicalCondition: false,
};

export const useAssessmentStore = create<AssessmentState>()(
  persist(
    (set) => ({
      draft: {
        phaseA: { ...defaultPhaseA },
      },
      setPhaseA: (data) =>
        set((state) => ({
          draft: {
            ...state.draft,
            phaseA: { ...state.draft.phaseA, ...data },
          },
        })),
      setPhaseB: (data) =>
        set((state) => ({
          draft: {
            ...state.draft,
            phaseB: { ...state.draft.phaseB, ...data } as PhaseBInput, // Will ensure initialization happens elsewhere if undefined
          },
        })),
      setPhaseC: (data) =>
        set((state) => ({
          draft: {
            ...state.draft,
            phaseC: { ...state.draft.phaseC, ...data } as PhaseCInput,
          },
        })),
      reset: () =>
        set({
          draft: { phaseA: { ...defaultPhaseA } },
        }),
    }),
    {
      name: "assessment-storage",
      storage: createJSONStorage(() => {
        if (typeof window !== "undefined") {
          return sessionStorage;
        }
        return {
          getItem: () => null,
          setItem: () => {},
          removeItem: () => {},
        } as any;
      }), // Use sessionStorage to persist across refresh but clear on tab close (matches mobile intent of short session)
    }
  )
);
