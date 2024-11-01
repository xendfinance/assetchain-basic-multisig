type Props = {
    children: any
}
export function Empty(props: Props){
    return <div className="flex items-center justify-center w-full h-full">
        {props.children}
    </div>
}