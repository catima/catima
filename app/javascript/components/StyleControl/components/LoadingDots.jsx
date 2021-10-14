import React from 'react';
import styled, {keyframes} from "styled-components";

const BounceAnimation = keyframes`
  {0%,80%,100%{opacity:0;}40%{opacity:1;}};
`;

const DotWrapper = styled.div`
  display: flex;
  align-items: flex-end;
  height: 20px;
`;

const Dot = styled.span`
  background-color: black;
  border-radius: 50%;
  width: 5px;
  height: 5px;
  margin: 0 2.5px;

  /* Animation */
  animation: ${BounceAnimation} 1s ease-in-out infinite;
  animation-delay: ${props => props.delay};
`;

const LoadingDots = () => {
  return (
    <DotWrapper>
      <Dot delay="0s"/>
      <Dot delay=".1s"/>
      <Dot delay=".2s"/>
    </DotWrapper>
  )
}

export default LoadingDots
