import { useEffect, useRef } from 'react';

interface NuiEventData {
  [key: string]: any;
}

type NuiEventHandler = (data: NuiEventData) => void;

interface NuiEventMap {
  [eventName: string]: NuiEventHandler[];
}

const nuiEventMap: NuiEventMap = {};

// Global event listener for NUI messages
window.addEventListener('message', (event) => {
  const { type, data } = event.data;
  
  if (nuiEventMap[type]) {
    nuiEventMap[type].forEach(handler => {
      try {
        handler(data);
      } catch (error) {
        console.error(`Error in NUI event handler for ${type}:`, error);
      }
    });
  }
});

export const useNuiEvent = (eventName: string, handler: NuiEventHandler) => {
  const handlerRef = useRef(handler);
  
  // Update handler ref when handler changes
  useEffect(() => {
    handlerRef.current = handler;
  }, [handler]);
  
  useEffect(() => {
    // Create wrapper that uses the current handler
    const wrappedHandler = (data: NuiEventData) => {
      handlerRef.current(data);
    };
    
    // Add to event map
    if (!nuiEventMap[eventName]) {
      nuiEventMap[eventName] = [];
    }
    nuiEventMap[eventName].push(wrappedHandler);
    
    // Cleanup function
    return () => {
      const index = nuiEventMap[eventName].indexOf(wrappedHandler);
      if (index > -1) {
        nuiEventMap[eventName].splice(index, 1);
      }
      
      // Clean up empty arrays
      if (nuiEventMap[eventName].length === 0) {
        delete nuiEventMap[eventName];
      }
    };
  }, [eventName]);
};

// Utility function to send NUI messages to the game client
export const sendNuiMessage = (type: string, data?: any) => {
  if (typeof window !== 'undefined' && (window as any).invokeNative) {
    // FiveM environment
    fetch(`https://${GetParentResourceName()}/${type}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data || {}),
    }).catch(console.error);
  } else {
    // Development environment - log to console
    console.log('NUI Message:', { type, data });
  }
};

// Utility function to get the current resource name (for development)
const GetParentResourceName = (): string => {
  // In development, return a default name
  if (typeof window !== 'undefined' && !(window as any).invokeNative) {
    return 'district-zero';
  }
  
  // In FiveM, this would be available
  return (window as any).GetParentResourceName?.() || 'district-zero';
}; 